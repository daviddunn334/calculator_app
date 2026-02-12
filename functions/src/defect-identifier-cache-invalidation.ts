import {onObjectFinalized, onObjectDeleted} from "firebase-functions/v2/storage";
import {logger} from "firebase-functions";
import {invalidateDefectIdentifierCache} from "./defect-identifier-cache-manager";

/**
 * Triggers when a file is uploaded to Firebase Storage
 * Invalidates cache if the file is a defect identifier PDF
 */
export const invalidateDefectIdentifierCacheOnUpload = onObjectFinalized(
  {
    bucket: "integrity-tools.appspot.com",
    region: "us-central1",
  },
  async (event) => {
    const filePath = event.data.name;

    // Only watch defect identifier folder
    if (!filePath || !filePath.startsWith("procedures/defectidentifiertool/")) {
      return;
    }

    // Only watch PDF files
    if (!filePath.endsWith(".pdf")) {
      return;
    }

    logger.info(
      `📤 PDF uploaded for defect identifier: ${filePath}. Invalidating cache...`
    );

    try {
      await invalidateDefectIdentifierCache();
      logger.info("✅ Defect identifier cache invalidated");
    } catch (error) {
      logger.error("Error invalidating defect identifier cache:", error);
    }
  }
);

/**
 * Triggers when a file is deleted from Firebase Storage
 * Invalidates cache if the file was a defect identifier PDF
 */
export const invalidateDefectIdentifierCacheOnDelete = onObjectDeleted(
  {
    bucket: "integrity-tools.appspot.com",
    region: "us-central1",
  },
  async (event) => {
    const filePath = event.data.name;

    // Only watch defect identifier folder
    if (!filePath || !filePath.startsWith("procedures/defectidentifiertool/")) {
      return;
    }

    // Only watch PDF files
    if (!filePath.endsWith(".pdf")) {
      return;
    }

    logger.info(
      `🗑️ PDF deleted for defect identifier: ${filePath}. Invalidating cache...`
    );

    try {
      await invalidateDefectIdentifierCache();
      logger.info("✅ Defect identifier cache invalidated");
    } catch (error) {
      logger.error("Error invalidating defect identifier cache:", error);
    }
  }
);
