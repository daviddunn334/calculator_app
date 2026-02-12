import {onRequest} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {initializeApp} from "firebase-admin/app";
import {getStorage} from "firebase-admin/storage";
import * as pdfParse from "pdf-parse";
import * as ExcelJS from "exceljs";

initializeApp();

// Export the defect analysis function
export {analyzeDefectOnCreate} from "./defect-analysis";

// Export cache invalidation functions
export {
  invalidateCacheOnPdfUpload,
  invalidateCacheOnPdfDelete,
} from "./cache-invalidation";

// Export defect photo identification function (Firestore trigger)
export {analyzePhotoIdentificationOnCreate} from "./defect-photo-identification";

// Export defect identifier cache invalidation functions
export {
  invalidateDefectIdentifierCacheOnUpload,
  invalidateDefectIdentifierCacheOnDelete,
} from "./defect-identifier-cache-invalidation";

// Export Method Hours export function
export {exportMethodHoursToExcel} from "./method-hours-export";

export const processHardnessReport = onRequest({cors: true}, async (req, res) => {
  try {
    const {filePath} = req.body;

    if (!filePath) {
      res.status(400).json({error: "File path is required"});
      return;
    }

    if (!filePath.endsWith(".pdf")) {
      res.status(400).json({error: "This is not a PDF file."});
      return;
    }

    if (!filePath.startsWith("uploads/")) {
      res.status(400).json({error: "File is not in the uploads directory."});
      return;
    }

    const storage = getStorage();
    const bucket = storage.bucket();
    const pdfFile = bucket.file(filePath);

    // Check if PDF file exists
    const [exists] = await pdfFile.exists();
    if (!exists) {
      res.status(404).json({error: "PDF file not found"});
      return;
    }

    const [pdfBuffer] = await pdfFile.download();
    const data = await pdfParse.default(pdfBuffer);
    const hardnessValues = parseHardnessValues(data.text);

    // Check if template exists
    const templateFile = bucket.file("assets/files/Hardness Test Field Results Template (Auto) - Copy.xlsx");
    const [templateExists] = await templateFile.exists();
    if (!templateExists) {
      res.status(404).json({error: "Excel template not found"});
      return;
    }

    const [templateBuffer] = await templateFile.download();
    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.load(templateBuffer);
    const worksheet = workbook.getWorksheet(1);

    if (!worksheet) {
      res.status(500).json({error: "Worksheet not found."});
      return;
    }

    // Insert hardness values into the template
    // First 84 values in 2-column, 42-row layout starting at A1
    for (let i = 0; i < Math.min(hardnessValues.length, 84); i++) {
      const row = Math.floor(i / 2) + 1;
      const col = (i % 2) + 1;
      const cellRef = String.fromCharCode(64 + col) + row; // A1, B1, A2, B2, etc.
      worksheet.getCell(cellRef).value = hardnessValues[i];
    }

    // Remaining values in continuation area (starting at column D)
    if (hardnessValues.length > 84) {
      for (let i = 84; i < hardnessValues.length; i++) {
        const row = (i - 84) + 1;
        worksheet.getCell(`D${row}`).value = hardnessValues[i];
      }
    }

    const outputFileName = `processed/${filePath.split("/").pop()?.replace(".pdf", ".xlsx")}`;
    const outputFile = bucket.file(outputFileName);

    const buffer = await workbook.xlsx.writeBuffer();
    await outputFile.save(buffer as Buffer);

    // Make the output file publicly accessible
    await outputFile.makePublic();
    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${outputFileName}`;

    logger.log(`Successfully processed ${filePath} and saved to ${outputFileName}`);
    res.json({
      success: true,
      message: `Successfully processed ${filePath} and saved to ${outputFileName}`,
      outputFile: outputFileName,
      downloadUrl: publicUrl,
      hardnessValues: hardnessValues,
      totalValues: hardnessValues.length,
    });
  } catch (error) {
    logger.error("Error processing hardness report:", error);
    res.status(500).json({error: "Internal server error", details: error});
  }
});

/**
 * Parses hardness values from a string of text.
 * @param {string} text The text to parse.
 * @return {number[]} An array of hardness values.
 */
function parseHardnessValues(text: string): number[] {
  const values: number[] = [];
  const lines = text.split("\n");

  for (const line of lines) {
    // Look for patterns like "123.4" or "567.89"
    const numbers = line.match(/\b\d{2,3}\.\d{1,2}\b/g) || [];
    for (const number of numbers) {
      const value = parseFloat(number);
      // Filter reasonable hardness values (typically 100-800 range)
      if (value >= 100 && value <= 1000) {
        values.push(value);
      }
    }
  }

  return values;
}
