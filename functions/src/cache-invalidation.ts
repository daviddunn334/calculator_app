import {onObjectFinalized, onObjectDeleted} from "firebase-functions/v2/storage";
import {logger} from "firebase-functions";
import {invalidateCacheForClient} from "./cache-manager";

/**
 * Triggers when a file is uploaded to Firebase Storage
 * Invalidates cache if the file is a procedure PDF
 */
export const invalidateCacheOnPdfUpload = onObjectFinalized(
  {
    bucket: "ndt-toolkit.appspot.com",
    region: "us-central1",
  },
  async (event) => {
    const filePath = event.data.name;

    // Only watch procedures folder
    if (!filePath || !filePath.startsWith("procedures/")) {
      return;
    }

    // Only watch PDF files
    if (!filePath.endsWith(".pdf")) {
      return;
    }

    // Extract client name from path: procedures/{clientName}/file.pdf
    const pathParts = filePath.split("/");
    if (pathParts.length < 3) {
      logger.warn(`Invalid procedure path structure: ${filePath}`);
      return;
    }

    const clientName = pathParts[1];

    logger.info(
      `📤 PDF uploaded for ${clientName}: ${filePath}. Invalidating cache...`
    );

    try {
      await invalidateCacheForClient(clientName);
      logger.info(`✅ Cache invalidated for ${clientName}`);
    } catch (error) {
      logger.error(`Error invalidating cache for ${clientName}:`, error);
    }
  }
);

/**
 * Triggers when a file is deleted from Firebase Storage
 * Invalidates cache if the file was a procedure PDF
 */
export const invalidateCacheOnPdfDelete = onObjectDeleted(
  {
    bucket: "ndt-toolkit.appspot.com",
    region: "us-central1",
  },
  async (event) => {
    const filePath = event.data.name;

    // Only watch procedures folder
    if (!filePath || !filePath.startsWith("procedures/")) {
      return;
    }

    // Only watch PDF files
    if (!filePath.endsWith(".pdf")) {
      return;
    }

    // Extract client name from path: procedures/{clientName}/file.pdf
    const pathParts = filePath.split("/");
    if (pathParts.length < 3) {
      logger.warn(`Invalid procedure path structure: ${filePath}`);
      return;
    }

    const clientName = pathParts[1];

    logger.info(
      `🗑️ PDF deleted for ${clientName}: ${filePath}. Invalidating cache...`
    );

    try {
      await invalidateCacheForClient(clientName);
      logger.info(`✅ Cache invalidated for ${clientName}`);
    } catch (error) {
      logger.error(`Error invalidating cache for ${clientName}:`, error);
    }
  }
);
