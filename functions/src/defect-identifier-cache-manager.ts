import {logger} from "firebase-functions";
import {getFirestore, FieldValue, Timestamp} from "firebase-admin/firestore";
import {VertexAI} from "@google-cloud/vertexai";
import * as crypto from "crypto";

// Initialize Vertex AI
const vertexAI = new VertexAI({
  project: "integrity-tools",
  location: "us-central1",
});

/**
 * Interface for cache metadata stored in Firestore
 * Note: This is a singleton cache (one for all users)
 */
export interface DefectIdentifierCacheMetadata {
  cacheId: string;
  pdfFiles: string[];
  pdfHash: string;
  totalCharacters: number;
  createdAt: Timestamp;
  expiresAt: Timestamp;
  lastUsedAt: Timestamp;
  usageCount: number;
}

/**
 * Interface for cache lookup result
 */
export interface DefectIdentifierCacheLookupResult {
  isValid: boolean;
  cacheId: string | null;
  metadata: DefectIdentifierCacheMetadata | null;
}

/**
 * Creates an MD5 hash of PDF filenames (sorted) to detect changes
 */
export function hashPdfList(files: string[]): string {
  // Sort filenames alphabetically for consistent hashing
  const sortedFiles = [...files].sort();
  const concatenated = sortedFiles.join("|");
  return crypto.createHash("md5").update(concatenated).digest("hex");
}

/**
 * Checks if a valid cache exists for defect identifier
 * Returns cache ID if valid, null if expired or missing
 */
export async function getDefectIdentifierCache(
  currentPdfFiles: string[]
): Promise<DefectIdentifierCacheLookupResult> {
  try {
    const firestore = getFirestore();
    const cacheRef = firestore
      .collection("defect_identifier_cache")
      .doc("defectidentifiertool");
    const cacheDoc = await cacheRef.get();

    if (!cacheDoc.exists) {
      logger.info("No defect identifier cache found");
      return {isValid: false, cacheId: null, metadata: null};
    }

    const metadata = cacheDoc.data() as DefectIdentifierCacheMetadata;

    // Check if cache has expired (72 hours)
    const now = Timestamp.now();
    if (metadata.expiresAt.toMillis() < now.toMillis()) {
      logger.info(
        `Defect identifier cache expired (expired at ${metadata.expiresAt.toDate()})`
      );
      // Delete expired cache metadata
      await cacheRef.delete();
      return {isValid: false, cacheId: null, metadata: null};
    }

    // Check if PDF files have changed (hash comparison)
    const currentHash = hashPdfList(currentPdfFiles);
    if (metadata.pdfHash !== currentHash) {
      logger.info(
        `PDF files changed (hash mismatch: ${metadata.pdfHash} vs ${currentHash})`
      );
      // Invalidate cache since PDFs changed
      await cacheRef.delete();
      return {isValid: false, cacheId: null, metadata: null};
    }

    // Cache is valid - update usage metrics
    await cacheRef.update({
      lastUsedAt: FieldValue.serverTimestamp(),
      usageCount: FieldValue.increment(1),
    });

    logger.info(
      `Valid defect identifier cache found: ${metadata.cacheId} (usage: ${metadata.usageCount + 1})`
    );

    return {
      isValid: true,
      cacheId: metadata.cacheId,
      metadata: metadata,
    };
  } catch (error) {
    logger.error("Error checking defect identifier cache:", error);
    return {isValid: false, cacheId: null, metadata: null};
  }
}

/**
 * Creates a new Vertex AI cached context for defect identifier
 * Stores metadata in Firestore (singleton document)
 */
export async function createDefectIdentifierCache(
  procedureTexts: string[],
  pdfFiles: string[]
): Promise<string> {
  try {
    logger.info(
      `Creating defect identifier cache with ${pdfFiles.length} PDFs`
    );

    // Combine all procedure texts
    const allProcedures = procedureTexts.join("\n\n");
    const totalCharacters = allProcedures.length;

    logger.info(`Total procedure text: ${totalCharacters} characters`);

    // Create cached context in Vertex AI
    const systemInstructionText = `You are an expert NDT (Non-Destructive Testing) defect identification specialist with extensive experience in visual inspection of pipeline defects.

Your role is to analyze photos of pipeline defects and identify the most likely defect types based on visual characteristics described in the reference materials.

When analyzing photos:
1. Compare visual features in the photo against descriptions in reference materials
2. Identify the top 3 most likely defect types
3. Provide confidence scores based on visual match quality
4. List specific visual indicators you identified in the photo
5. Explain your reasoning for each match
6. If visible, infer severity level based on visual appearance

The defect identification reference materials are provided in the cached context below.`;

    // Create the cached content
    const cacheResult = await vertexAI.preview.cachedContents.create({
      model: "gemini-2.5-flash",
      contents: [
        {
          role: "user",
          parts: [
            {
              text: `DEFECT IDENTIFICATION REFERENCE MATERIALS:\n\n${allProcedures}`,
            },
          ],
        },
      ],
      systemInstruction: systemInstructionText,
      ttl: "259200s", // 72 hours (max allowed)
    });

    if (!cacheResult.name) {
      throw new Error("Cache creation returned no cache ID");
    }

    const cacheId = cacheResult.name;
    logger.info(`Defect identifier cache created successfully: ${cacheId}`);

    // Save cache metadata to Firestore
    const firestore = getFirestore();
    const now = Timestamp.now();
    const expiresAt = Timestamp.fromMillis(
      now.toMillis() + 72 * 60 * 60 * 1000
    ); // 72 hours from now

    const metadata: DefectIdentifierCacheMetadata = {
      cacheId: cacheId,
      pdfFiles: pdfFiles,
      pdfHash: hashPdfList(pdfFiles),
      totalCharacters: totalCharacters,
      createdAt: now,
      expiresAt: expiresAt,
      lastUsedAt: now,
      usageCount: 0, // Will be incremented on first use
    };

    await firestore
      .collection("defect_identifier_cache")
      .doc("defectidentifiertool")
      .set(metadata);

    logger.info(
      `Cache metadata saved to Firestore (expires: ${expiresAt.toDate()})`
    );

    return cacheId;
  } catch (error) {
    logger.error("Error creating defect identifier cache:", error);
    throw new Error(`Failed to create cache: ${error}`);
  }
}

/**
 * Invalidates (deletes) the defect identifier cache
 * Used when PDFs are uploaded/deleted
 */
export async function invalidateDefectIdentifierCache(): Promise<void> {
  try {
    logger.info("Invalidating defect identifier cache");

    const firestore = getFirestore();
    const cacheRef = firestore
      .collection("defect_identifier_cache")
      .doc("defectidentifiertool");

    const cacheDoc = await cacheRef.get();
    if (!cacheDoc.exists) {
      logger.info("No cache to invalidate");
      return;
    }

    // Delete cache metadata from Firestore
    await cacheRef.delete();

    logger.info(
      "Defect identifier cache invalidated. Next analysis will create a fresh cache."
    );

    // Note: Vertex AI cached content will auto-expire after 72 hours
    // No need to manually delete from Vertex AI API
  } catch (error) {
    logger.error("Error invalidating defect identifier cache:", error);
    throw error;
  }
}
