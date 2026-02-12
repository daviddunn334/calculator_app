import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions";
import {getFirestore} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {VertexAI} from "@google-cloud/vertexai";
import * as pdfParse from "pdf-parse";
import {
  getDefectIdentifierCache,
  createDefectIdentifierCache,
} from "./defect-identifier-cache-manager";

// Initialize Vertex AI
const vertexAI = new VertexAI({
  project: "integrity-tools",
  location: "us-central1",
});

/**
 * Firestore trigger to analyze photo identifications on create
 * Triggers when a new document is created in /photo_identifications/
 */
export const analyzePhotoIdentificationOnCreate = onDocumentCreated(
  "photo_identifications/{photoId}",
  async (event) => {
    const startTime = Date.now();
    const photoId = event.params.photoId;
    const db = getFirestore();
    const photoRef = db.collection("photo_identifications").doc(photoId);

    try {
      // Get document data
      const docData = event.data?.data();

      if (!docData) {
        logger.error(`No data found for photo ID: ${photoId}`);
        return;
      }

      const {photoUrl, userId} = docData;

      if (!photoUrl || !userId) {
        logger.error(`Missing photoUrl or userId for photo ID: ${photoId}`);
        await photoRef.update({
          analysisStatus: "error",
          errorMessage: "Invalid photo data - missing required fields",
        });
        return;
      }

      logger.info(
        `Starting defect identification for user ${userId} with photo ID: ${photoId}`
      );

      // Step 0: Set status to "analyzing"
      await photoRef.update({
        analysisStatus: "analyzing",
      });

      // Step 1: Download photo from Storage
      const photoBuffer = await downloadPhotoFromUrl(photoUrl);
      const base64Image = photoBuffer.toString("base64");

      logger.info(
        `Photo downloaded successfully (${photoBuffer.length} bytes)`
      );

      // Step 2: Get list of PDF files
      const pdfFileNames = await getPdfFileNames();

      if (pdfFileNames.length === 0) {
        throw new Error(
          "No defect identification reference PDFs found in procedures/defectidentifiertool/"
        );
      }

      // Step 3: Check for cached context or create new one
      logger.info("Checking cache for defect identifier...");

      const cacheResult = await getDefectIdentifierCache(pdfFileNames);

      let cacheId: string;

      if (cacheResult.isValid && cacheResult.cacheId) {
        // Use existing cache (FAST PATH)
        logger.info("✅ Using cached context (cache hit!)");
        cacheId = cacheResult.cacheId;
      } else {
        // Create new cache (SLOW PATH - first time or expired)
        logger.info(
          "⚠️ No valid cache found. Creating new cache for defect identifier..."
        );

        // Fetch and extract procedure PDFs
        const procedureTexts = await fetchDefectIdentifierProcedures();

        logger.info(
          `Extracted text from ${procedureTexts.length} procedure document(s)`
        );

        // Create the cache
        cacheId = await createDefectIdentifierCache(
          procedureTexts,
          pdfFileNames
        );

        logger.info(`✅ Cache created successfully: ${cacheId}`);
      }

      // Step 4: Build AI prompt
      const prompt = buildIdentificationPrompt();

      // Step 5: Call Gemini Vision API with cached context
      logger.info("Calling Gemini Vision API with cached context");
      const analysisResult = await callGeminiVisionAPI(
        cacheId,
        base64Image,
        prompt
      );

      // Step 6: Parse and validate AI response
      const parsedResult = parseAIResponse(analysisResult);

      const processingTime = (Date.now() - startTime) / 1000; // seconds
      logger.info(
        `Defect identification complete in ${processingTime.toFixed(1)}s`
      );

      // Step 7: Update Firestore document with results
      await photoRef.update({
        analysisStatus: "complete",
        analysisCompletedAt: new Date(),
        matches: parsedResult.matches,
        processingTime: processingTime,
      });

      logger.info(`✅ Photo ${photoId} analysis saved to Firestore`);
    } catch (error: any) {
      logger.error(`Error analyzing photo ${photoId}:`, error);

      // Update document with error status
      try {
        await photoRef.update({
          analysisStatus: "error",
          errorMessage: error.message || "Unknown error during analysis",
          analysisCompletedAt: new Date(),
        });
      } catch (updateError) {
        logger.error("Error updating document with error status:", updateError);
      }
    }
  }
);

/**
 * Downloads photo from Firebase Storage URL
 */
async function downloadPhotoFromUrl(photoUrl: string): Promise<Buffer> {
  try {
    const storage = getStorage();
    const bucket = storage.bucket();

    // Extract path from URL
    // URL format: https://firebasestorage.googleapis.com/.../o/path%2Fto%2Ffile?...
    const urlObj = new URL(photoUrl);
    const pathMatch = urlObj.pathname.match(/\/o\/(.+?)(\?|$)/);

    if (!pathMatch) {
      throw new Error("Could not extract file path from URL");
    }

    const encodedPath = pathMatch[1];
    const filePath = decodeURIComponent(encodedPath);

    logger.info(`Downloading photo from: ${filePath}`);

    const file = bucket.file(filePath);
    const [buffer] = await file.download();

    return buffer;
  } catch (error) {
    logger.error("Error downloading photo:", error);
    throw new Error(`Failed to download photo: ${error}`);
  }
}

/**
 * Gets list of PDF filenames in defect identifier folder
 */
async function getPdfFileNames(): Promise<string[]> {
  try {
    const storage = getStorage();
    const bucket = storage.bucket();

    // List all files in the defect identifier procedure folder
    const folderPath = "procedures/defectidentifiertool/";
    const [files] = await bucket.getFiles({
      prefix: folderPath,
    });

    // Filter for PDF files only and extract names
    const pdfFileNames = files
      .filter((file) => file.name.endsWith(".pdf"))
      .map((file) => file.name);

    logger.info(`Found ${pdfFileNames.length} PDF file(s) in defect identifier folder`);

    return pdfFileNames;
  } catch (error) {
    logger.error("Error getting PDF file names:", error);
    return [];
  }
}

/**
 * Fetches all defect identifier PDFs from Firebase Storage
 * and extracts text from them
 */
async function fetchDefectIdentifierProcedures(): Promise<string[]> {
  try {
    const storage = getStorage();
    const bucket = storage.bucket();

    // List all files in the folder
    const folderPath = "procedures/defectidentifiertool/";
    const [files] = await bucket.getFiles({
      prefix: folderPath,
    });

    // Filter for PDF files only
    const pdfFiles = files.filter((file) => file.name.endsWith(".pdf"));

    if (pdfFiles.length === 0) {
      logger.warn(`No PDF files found in ${folderPath}`);
      return [];
    }

    logger.info(`Found ${pdfFiles.length} PDF file(s) for defect identifier`);

    // Extract text from each PDF
    const procedureTexts: string[] = [];
    for (const file of pdfFiles) {
      try {
        logger.info(`Processing PDF: ${file.name}`);
        const [buffer] = await file.download();
        const data = await pdfParse.default(buffer);

        if (data.text && data.text.trim().length > 0) {
          procedureTexts.push(`\n=== ${file.name} ===\n${data.text}\n`);
          logger.info(
            `Extracted ${data.text.length} characters from ${file.name}`
          );
        } else {
          logger.warn(`No text extracted from ${file.name}`);
        }
      } catch (pdfError) {
        logger.error(`Error processing ${file.name}:`, pdfError);
        // Continue with other PDFs even if one fails
      }
    }

    return procedureTexts;
  } catch (error) {
    logger.error("Error fetching defect identifier procedures:", error);
    throw error;
  }
}

/**
 * Builds the identification prompt for the AI
 */
function buildIdentificationPrompt(): string {
  return `DEFECT IDENTIFICATION FROM PHOTO:

Analyze the attached photo and identify the top 3 most likely defect types based on visual characteristics described in the reference materials.

For each of the top 3 matches, provide:
1. Defect type name (e.g., "Corrosion", "Dent", "Crack", etc.)
2. Confidence level: "high" (80-100%), "medium" (50-79%), or "low" (0-49%)
3. Confidence score: specific percentage (0-100)
4. Visual indicators: list of specific features you identified in the photo
5. Reasoning: explanation for why this defect type matches the photo
6. Severity (optional): if visible characteristics allow assessment, provide "low", "medium", "high", or "critical"

Consider:
- Surface texture and appearance
- Color variations
- Shape and geometry
- Pattern characteristics
- Extent and distribution
- Any visible measurements or scale

RESPONSE FORMAT (CRITICAL):
Output ONLY a valid JSON object. NO markdown, NO conversational text, NO code fences.

{
  "matches": [
    {
      "defectType": "string",
      "confidence": "high|medium|low",
      "confidenceScore": 0-100,
      "visualIndicators": ["indicator1", "indicator2", "indicator3"],
      "reasoning": "detailed explanation",
      "severity": "low|medium|high|critical|unknown"
    }
  ]
}

Provide exactly 3 matches in descending order of confidence.`;
}

/**
 * Calls Gemini Vision API with cached context and image
 */
async function callGeminiVisionAPI(
  cacheId: string,
  base64Image: string,
  prompt: string
): Promise<string> {
  try {
    // Create model with cached content reference
    const model = vertexAI.getGenerativeModel({
      model: "gemini-2.5-flash",
      cachedContent: {name: cacheId} as any,
    });

    const result = await model.generateContent({
      contents: [
        {
          role: "user",
          parts: [
            {
              inlineData: {
                mimeType: "image/jpeg",
                data: base64Image,
              },
            },
            {
              text: prompt,
            },
          ],
        },
      ],
      generationConfig: {
        temperature: 0.2,
        maxOutputTokens: 4096,
        responseMimeType: "application/json",
      },
    });

    const response = result.response;

    // Extract text from the response
    const text = response.candidates?.[0]?.content?.parts?.[0]?.text || "";

    if (!text) {
      throw new Error("No text content in AI response");
    }

    logger.info("✅ Received response from Gemini Vision API (using cached context)");
    logger.info(`Response length: ${text.length} characters`);

    // Log first 500 chars for debugging
    logger.info(`Response preview: ${text.substring(0, 500)}...`);

    return text;
  } catch (error) {
    logger.error("Error calling Gemini Vision API:", error);
    throw new Error("Failed to get AI analysis");
  }
}

/**
 * Cleans and extracts valid JSON from AI response
 */
function cleanAndExtractJSON(rawText: string): string {
  try {
    logger.info("Cleaning AI response...");

    // Step 1: Remove markdown code fences if present
    let cleaned = rawText.trim();

    // Remove ```json and ``` wrappers
    if (cleaned.startsWith("```json")) {
      cleaned = cleaned.substring(7); // Remove ```json
    } else if (cleaned.startsWith("```")) {
      cleaned = cleaned.substring(3); // Remove ```
    }

    if (cleaned.endsWith("```")) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    cleaned = cleaned.trim();

    // Step 2: Find the first { and last } to extract pure JSON
    const firstBrace = cleaned.indexOf("{");
    const lastBrace = cleaned.lastIndexOf("}");

    if (firstBrace === -1 || lastBrace === -1 || firstBrace >= lastBrace) {
      logger.error("No valid JSON braces found in response");
      throw new Error("Response does not contain valid JSON object");
    }

    // Extract JSON between braces
    const jsonString = cleaned.substring(firstBrace, lastBrace + 1);

    logger.info(`Extracted JSON string (${jsonString.length} chars)`);

    // Step 3: Check for potential truncation
    if (rawText.length >= 4090) {
      logger.warn("Response may be truncated - close to token limit");
    }

    return jsonString;
  } catch (error) {
    logger.error("Error cleaning JSON:", error);
    throw error;
  }
}

/**
 * Parses and validates the AI response
 */
function parseAIResponse(responseText: string): {
  matches: Array<{
    defectType: string;
    confidence: string;
    confidenceScore: number;
    visualIndicators: string[];
    reasoning: string;
    severity?: string;
  }>;
} {
  try {
    // Log the raw response for debugging
    logger.info("Raw AI response:");
    logger.info(responseText.substring(0, 1000)); // Log first 1000 chars

    // Step 1: Clean and extract JSON
    const cleanedJSON = cleanAndExtractJSON(responseText);

    // Step 2: Parse the cleaned JSON
    const parsed = JSON.parse(cleanedJSON);

    logger.info("Successfully parsed JSON");

    // Step 3: Validate structure
    if (!parsed.matches || !Array.isArray(parsed.matches)) {
      throw new Error("Invalid response structure - missing matches array");
    }

    if (parsed.matches.length === 0) {
      throw new Error("No matches returned in response");
    }

    // Step 4: Validate each match
    const validatedMatches = parsed.matches.slice(0, 3).map((match: any, index: number) => {
      if (!match.defectType || typeof match.defectType !== "string") {
        throw new Error(`Match ${index + 1}: Invalid defectType field`);
      }

      if (!["high", "medium", "low"].includes(match.confidence)) {
        throw new Error(`Match ${index + 1}: Invalid confidence field: ${match.confidence}`);
      }

      if (typeof match.confidenceScore !== "number" || match.confidenceScore < 0 || match.confidenceScore > 100) {
        throw new Error(`Match ${index + 1}: Invalid confidenceScore: ${match.confidenceScore}`);
      }

      if (!Array.isArray(match.visualIndicators)) {
        throw new Error(`Match ${index + 1}: Invalid visualIndicators field`);
      }

      if (!match.reasoning || typeof match.reasoning !== "string") {
        throw new Error(`Match ${index + 1}: Invalid reasoning field`);
      }

      // Severity is optional
      const severity = match.severity && ["low", "medium", "high", "critical", "unknown"].includes(match.severity)
        ? match.severity
        : "unknown";

      return {
        defectType: match.defectType,
        confidence: match.confidence,
        confidenceScore: match.confidenceScore,
        visualIndicators: match.visualIndicators,
        reasoning: match.reasoning,
        severity: severity,
      };
    });

    logger.info(`Validation passed - ${validatedMatches.length} matches validated`);

    return {matches: validatedMatches};
  } catch (error: any) {
    logger.error("Error parsing AI response:", error);
    logger.error("Full response text:", responseText);

    // Provide more helpful error message
    if (error instanceof SyntaxError) {
      throw new Error(
        `JSON parsing failed: ${error.message}. Response may be truncated or contain invalid characters.`
      );
    }

    throw new Error(`Failed to parse AI response: ${error.message}`);
  }
}
