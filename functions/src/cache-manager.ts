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
 */
export interface CacheMetadata {
  clientName: string;
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
export interface CacheLookupResult {
  isValid: boolean;
  cacheId: string | null;
  metadata: CacheMetadata | null;
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
 * Checks if a valid cache exists for the given client
 * Returns cache ID if valid, null if expired or missing
 */
export async function getCacheForClient(
  clientName: string,
  currentPdfFiles: string[]
): Promise<CacheLookupResult> {
  try {
    const firestore = getFirestore();
    const cacheRef = firestore.collection("procedure_caches").doc(clientName);
    const cacheDoc = await cacheRef.get();

    if (!cacheDoc.exists) {
      logger.info(`No cache found for client: ${clientName}`);
      return {isValid: false, cacheId: null, metadata: null};
    }

    const metadata = cacheDoc.data() as CacheMetadata;

    // Check if cache has expired (72 hours)
    const now = Timestamp.now();
    if (metadata.expiresAt.toMillis() < now.toMillis()) {
      logger.info(
        `Cache expired for ${clientName} (expired at ${metadata.expiresAt.toDate()})`
      );
      // Delete expired cache metadata
      await cacheRef.delete();
      return {isValid: false, cacheId: null, metadata: null};
    }

    // Check if PDF files have changed (hash comparison)
    const currentHash = hashPdfList(currentPdfFiles);
    if (metadata.pdfHash !== currentHash) {
      logger.info(
        `PDF files changed for ${clientName} (hash mismatch: ${metadata.pdfHash} vs ${currentHash})`
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
      `Valid cache found for ${clientName}: ${metadata.cacheId} (usage: ${metadata.usageCount + 1})`
    );

    return {
      isValid: true,
      cacheId: metadata.cacheId,
      metadata: metadata,
    };
  } catch (error) {
    logger.error(`Error checking cache for ${clientName}:`, error);
    return {isValid: false, cacheId: null, metadata: null};
  }
}

/**
 * Creates a new Vertex AI cached context for the given client
 * Stores metadata in Firestore
 */
export async function createCacheForClient(
  clientName: string,
  procedureTexts: string[],
  pdfFiles: string[]
): Promise<string> {
  try {
    logger.info(`Creating cache for ${clientName} with ${pdfFiles.length} PDFs`);

    // Combine all procedure texts
    const allProcedures = procedureTexts.join("\n\n");
    const totalCharacters = allProcedures.length;

    logger.info(`Total procedure text: ${totalCharacters} characters`);

    // Create cached context in Vertex AI
    const systemInstructionText = `You are an expert pipeline integrity analyst specializing in NDT (Non-Destructive Testing) and defect evaluation. 

Your role is to analyze pipeline defects based on client-specific procedures and industry standards (ASME B31.8, API 1104, NACE, etc.).

When analyzing defects:
1. Reference exact thresholds from the procedures (e.g., "metal loss >80% requires repair")
2. Cite specific sections, tables, and page numbers from procedures
3. Be conservative - recommend consulting Asset Integrity when uncertain
4. Consider defect type, dimensions, location, and operating conditions
5. Provide clear, actionable recommendations for field technicians

The client procedures are provided in the cached context below.`;

    // Create the cached content
    const cacheResult = await vertexAI.preview.cachedContents.create({
      model: "gemini-2.5-flash",
      contents: [
        {
          role: "user",
          parts: [
            {
              text: `CLIENT PROCEDURES FOR ${clientName.toUpperCase()}:\n\n${allProcedures}`,
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
    logger.info(`Cache created successfully: ${cacheId}`);

    // Save cache metadata to Firestore
    const firestore = getFirestore();
    const now = Timestamp.now();
    const expiresAt = Timestamp.fromMillis(
      now.toMillis() + 72 * 60 * 60 * 1000
    ); // 72 hours from now

    const metadata: CacheMetadata = {
      clientName: clientName,
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
      .collection("procedure_caches")
      .doc(clientName)
      .set(metadata);

    logger.info(
      `Cache metadata saved to Firestore for ${clientName} (expires: ${expiresAt.toDate()})`
    );

    return cacheId;
  } catch (error) {
    logger.error(`Error creating cache for ${clientName}:`, error);
    throw new Error(`Failed to create cache: ${error}`);
  }
}

/**
 * Invalidates (deletes) the cache for a given client
 * Used when PDFs are uploaded/deleted or manual refresh is requested
 */
export async function invalidateCacheForClient(
  clientName: string
): Promise<void> {
  try {
    logger.info(`Invalidating cache for ${clientName}`);

    const firestore = getFirestore();
    const cacheRef = firestore.collection("procedure_caches").doc(clientName);

    const cacheDoc = await cacheRef.get();
    if (!cacheDoc.exists) {
      logger.info(`No cache to invalidate for ${clientName}`);
      return;
    }

    // Delete cache metadata from Firestore
    await cacheRef.delete();

    logger.info(
      `Cache invalidated for ${clientName}. Next analysis will create a fresh cache.`
    );

    // Note: Vertex AI cached content will auto-expire after 72 hours
    // No need to manually delete from Vertex AI API
  } catch (error) {
    logger.error(`Error invalidating cache for ${clientName}:`, error);
    throw error;
  }
}

/**
 * Gets all cache metadata (for monitoring/debugging)
 */
export async function getAllCacheMetadata(): Promise<CacheMetadata[]> {
  try {
    const firestore = getFirestore();
    const snapshot = await firestore.collection("procedure_caches").get();

    const caches: CacheMetadata[] = [];
    snapshot.forEach((doc) => {
      caches.push(doc.data() as CacheMetadata);
    });

    return caches;
  } catch (error) {
    logger.error("Error fetching cache metadata:", error);
    return [];
  }
}
