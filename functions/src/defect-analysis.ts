import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {VertexAI} from "@google-cloud/vertexai";
import * as pdfParse from "pdf-parse";
import {
  getCacheForClient,
  createCacheForClient,
} from "./cache-manager";

// Initialize Vertex AI
const vertexAI = new VertexAI({
  project: "integrity-tools",
  location: "us-central1",
});

/**
 * Cloud Function that triggers when a new defect is created
 * Analyzes the defect using Gemini AI and procedure PDFs
 */
export const analyzeDefectOnCreate = onDocumentCreated(
  "defect_entries/{defectId}",
  async (event) => {
    const defectId = event.params.defectId;
    const defectData = event.data?.data();

    if (!defectData) {
      logger.error("No defect data found");
      return;
    }

    const firestore = getFirestore();
    const defectRef = firestore.collection("defect_entries").doc(defectId);

    try {
      logger.info(`Starting analysis for defect ${defectId}`);

      // Step 1: Set status to 'analyzing'
      await defectRef.update({
        analysisStatus: "analyzing",
        analysisStartedAt: FieldValue.serverTimestamp(),
      });

      // Step 2: Check for cached context or create new one
      logger.info(`Checking cache for client: ${defectData.clientName}`);
      
      // First, get list of PDF files to check cache validity
      const pdfFileNames = await getPdfFileNames(defectData.clientName);
      
      if (pdfFileNames.length === 0) {
        throw new Error(
          `No procedure PDFs found for client: ${defectData.clientName}`
        );
      }
      
      // Check if valid cache exists
      const cacheResult = await getCacheForClient(
        defectData.clientName,
        pdfFileNames
      );
      
      let cacheId: string;
      
      if (cacheResult.isValid && cacheResult.cacheId) {
        // Use existing cache (FAST PATH)
        logger.info(
          `✅ Using cached context for ${defectData.clientName} (cache hit!)`
        );
        cacheId = cacheResult.cacheId;
      } else {
        // Create new cache (SLOW PATH - first time or expired)
        logger.info(
          `⚠️ No valid cache found. Creating new cache for ${defectData.clientName}...`
        );
        
        // Fetch and extract procedure PDFs
        const procedureTexts = await fetchClientProcedures(
          defectData.clientName
        );
        
        logger.info(
          `Extracted text from ${procedureTexts.length} procedure document(s)`
        );
        
        // Create the cache
        cacheId = await createCacheForClient(
          defectData.clientName,
          procedureTexts,
          pdfFileNames
        );
        
        logger.info(`✅ Cache created successfully: ${cacheId}`);
      }

      // Step 3: Build AI prompt with ONLY defect data (procedures are cached)
      const defectPrompt = buildDefectOnlyPrompt(defectData);

      // Step 4: Call Gemini AI with cached context
      logger.info("Calling Gemini AI with cached context");
      const analysisResult = await callGeminiAPIWithCache(cacheId, defectPrompt);

      // Step 5: Parse and validate AI response
      const parsedResult = parseAIResponse(analysisResult);

      // Step 6: Save results to Firestore
      await defectRef.update({
        analysisStatus: "complete",
        analysisCompletedAt: FieldValue.serverTimestamp(),
        repairRequired: parsedResult.repairRequired,
        repairType: parsedResult.repairType,
        severity: parsedResult.severity,
        aiRecommendations: parsedResult.recommendations,
        procedureReference: parsedResult.procedureReference,
        aiConfidence: parsedResult.confidence,
      });

      logger.info(`Successfully analyzed defect ${defectId}`);
    } catch (error: any) {
      logger.error(`Error analyzing defect ${defectId}:`, error);

      // Update status to error
      await defectRef.update({
        analysisStatus: "error",
        errorMessage: error.message || "Unknown error occurred",
        analysisCompletedAt: FieldValue.serverTimestamp(),
      });
    }
  }
);

/**
 * Gets list of PDF filenames for a client (without downloading)
 * Used for cache validation
 */
async function getPdfFileNames(clientName: string): Promise<string[]> {
  try {
    const storage = getStorage();
    const bucket = storage.bucket();

    // List all files in the client's procedure folder
    const folderPath = `procedures/${clientName}/`;
    const [files] = await bucket.getFiles({
      prefix: folderPath,
    });

    // Filter for PDF files only and extract names
    const pdfFileNames = files
      .filter((file) => file.name.endsWith(".pdf"))
      .map((file) => file.name);

    logger.info(`Found ${pdfFileNames.length} PDF file(s) for ${clientName}`);
    
    return pdfFileNames;
  } catch (error) {
    logger.error("Error getting PDF file names:", error);
    return [];
  }
}

/**
 * Fetches all procedure PDFs for a given client from Firebase Storage
 * and extracts text from them
 */
async function fetchClientProcedures(
  clientName: string
): Promise<string[]> {
  try {
    const storage = getStorage();
    const bucket = storage.bucket();

    // List all files in the client's procedure folder
    const folderPath = `procedures/${clientName}/`;
    const [files] = await bucket.getFiles({
      prefix: folderPath,
    });

    // Filter for PDF files only
    const pdfFiles = files.filter((file) => file.name.endsWith(".pdf"));

    if (pdfFiles.length === 0) {
      logger.warn(`No PDF files found in ${folderPath}`);
      return [];
    }

    logger.info(`Found ${pdfFiles.length} PDF file(s) for ${clientName}`);

    // Extract text from each PDF
    const procedureTexts: string[] = [];
    for (const file of pdfFiles) {
      try {
        logger.info(`Processing PDF: ${file.name}`);
        const [buffer] = await file.download();
        const data = await pdfParse.default(buffer);

        if (data.text && data.text.trim().length > 0) {
          procedureTexts.push(
            `\n=== ${file.name} ===\n${data.text}\n`
          );
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
    logger.error("Error fetching client procedures:", error);
    throw error;
  }
}

/**
 * Builds the defect-only prompt (procedures are in cached context)
 */
function buildDefectOnlyPrompt(defectData: any): string {
  const depthLabel = defectData.defectType
    .toLowerCase()
    .includes("hardspot") ? "Max HB" : "inches";
  
  // Calculate wall loss percentage if this is a metal loss defect
  const wallLossPercent = !defectData.defectType.toLowerCase().includes("hardspot")
    ? ((defectData.depth / defectData.pipeNWT) * 100).toFixed(1)
    : null;

  return `DEFECT ANALYSIS REQUEST:

PIPE SPECIFICATIONS:
- Pipe OD: ${defectData.pipeOD} inches
- Pipe NWT: ${defectData.pipeNWT} inches

DEFECT INFORMATION:
- Type: ${defectData.defectType}
- Length: ${defectData.length} inches
- Width: ${defectData.width} inches
- Depth/HB: ${defectData.depth} ${depthLabel}
${wallLossPercent ? `- Wall Loss: ${wallLossPercent}% (${defectData.depth} / ${defectData.pipeNWT})` : ""}
- Client: ${defectData.clientName}
${defectData.notes ? `- Notes: ${defectData.notes}` : ""}

TASK:
Analyze this defect based on the ${defectData.clientName} procedures in your context.

Provide:
1. Whether repair is required (based on procedure thresholds)
2. Recommended repair method (reference specific procedures)
3. Severity assessment (low/medium/high/critical)
4. Specific procedure references (sections, pages, tables)
5. Clear recommendations for the field technician

IMPORTANT:
- Use exact thresholds from procedures and pipe specifications
- Reference specific sections/tables
- Be conservative - recommend Asset Integrity if uncertain
- For hardspots: check if exceeds 300 BHN or cracking risk
- For dents: check if exceeds 6% of pipe OD (6% of ${defectData.pipeOD}" = ${(defectData.pipeOD * 0.06).toFixed(3)}")
- For metal loss: evaluate using RSTRENG/B31G if 10-80% wall loss
  ${wallLossPercent ? `(Current: ${wallLossPercent}% wall loss)` : ""}
- Consider pipe diameter and wall thickness in structural integrity assessment

RESPONSE FORMAT (CRITICAL):
Output ONLY a valid JSON object. NO markdown, NO conversational text.

{
  "repairRequired": true/false,
  "repairType": "specific method or null",
  "severity": "low/medium/high/critical",
  "recommendations": "detailed explanation with procedure references",
  "procedureReference": "specific sections/tables/pages",
  "confidence": "high/medium/low"
}`;
}

/**
 * Calls Gemini AI API with cached context
 */
async function callGeminiAPIWithCache(
  cacheId: string,
  defectPrompt: string
): Promise<string> {
  try {
    // Create model with cached content reference
    // The cacheId is the full resource name from Vertex AI
    const model = vertexAI.getGenerativeModel({
      model: "gemini-2.5-flash",
      cachedContent: {name: cacheId} as any, // 🔥 This is where the magic happens!
    });

    const result = await model.generateContent({
      contents: [
        {
          role: "user",
          parts: [{text: defectPrompt}],
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
    
    logger.info("✅ Received response from Gemini AI (using cached context)");
    logger.info(`Response length: ${text.length} characters`);
    
    // Log first 500 chars for debugging
    logger.info(`Response preview: ${text.substring(0, 500)}...`);
    
    return text;
  } catch (error) {
    logger.error("Error calling Gemini API:", error);
    throw new Error("Failed to get AI analysis");
  }
}

/**
 * Cleans and extracts valid JSON from AI response
 * Handles markdown wrappers, truncation, and malformed JSON
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
    if (rawText.length >= 4090) { // Close to 4096 token limit
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
  repairRequired: boolean;
  repairType: string | null;
  severity: string;
  recommendations: string;
  procedureReference: string;
  confidence: string;
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

    // Step 3: Validate required fields
    if (typeof parsed.repairRequired !== "boolean") {
      throw new Error("Invalid repairRequired field - must be boolean");
    }

    if (!["low", "medium", "high", "critical"].includes(parsed.severity)) {
      throw new Error(`Invalid severity field: ${parsed.severity}`);
    }

    if (!["high", "medium", "low"].includes(parsed.confidence)) {
      throw new Error(`Invalid confidence field: ${parsed.confidence}`);
    }

    logger.info("JSON validation passed");

    return {
      repairRequired: parsed.repairRequired,
      repairType: parsed.repairType || null,
      severity: parsed.severity,
      recommendations: parsed.recommendations || "No recommendations provided",
      procedureReference:
        parsed.procedureReference || "No specific reference provided",
      confidence: parsed.confidence,
    };
  } catch (error: any) {
    logger.error("Error parsing AI response:", error);
    logger.error("Full response text:", responseText);
    
    // Provide more helpful error message
    if (error instanceof SyntaxError) {
      throw new Error(`JSON parsing failed: ${error.message}. Response may be truncated or contain invalid characters.`);
    }
    
    throw new Error(`Failed to parse AI response: ${error.message}`);
  }
}
