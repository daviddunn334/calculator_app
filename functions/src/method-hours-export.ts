import {onCall, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {getFirestore} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import * as ExcelJS from "exceljs";

/**
 * Cloud Function to export Method Hours to Excel using server-side processing.
 * This avoids client-side Excel corruption issues by using the mature ExcelJS library.
 */
export const exportMethodHoursToExcel = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 120,
    memory: "512MiB",
  },
  async (request) => {
    try {
      // Verify authentication
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "User must be authenticated");
      }

      const userId = request.auth.uid;
      const {year} = request.data;

      if (!year || typeof year !== "number") {
        throw new HttpsError("invalid-argument", "Year parameter is required and must be a number");
      }

      logger.info(`Starting Method Hours export for user ${userId}, year ${year}`);

      // Step 1: Fetch user's method hours entries for the year
      const db = getFirestore();
      const startDate = new Date(year, 0, 1); // Jan 1
      const endDate = new Date(year, 11, 31, 23, 59, 59); // Dec 31

      const entriesSnapshot = await db
        .collection("method_hours")
        .where("userId", "==", userId)
        .where("date", ">=", startDate)
        .where("date", "<=", endDate)
        .orderBy("date", "asc")
        .get();

      logger.info(`Found ${entriesSnapshot.docs.length} entries for year ${year}`);

      // Step 2: Download template from Storage
      const storage = getStorage();
      const bucket = storage.bucket();
      const templatePath = "assets/templates/method_hours_template.xlsx";
      const templateFile = bucket.file(templatePath);

      const [templateExists] = await templateFile.exists();
      if (!templateExists) {
        throw new HttpsError("not-found", `Template not found at ${templatePath}`);
      }

      logger.info("Downloading template from Storage");
      const [templateBuffer] = await templateFile.download();

      // Step 3: Load template with ExcelJS
      const workbook = new ExcelJS.Workbook();
      // ExcelJS accepts Buffer directly
      // @ts-ignore - TypeScript has issues with Buffer types but this works at runtime
      await workbook.xlsx.load(templateBuffer);

      logger.info("Template loaded successfully, processing entries");

      // Step 4: Organize entries by date for quick lookup
      interface MethodHours {
        method: string;
        hours: number;
      }

      interface Entry {
        date: Date;
        location: string;
        supervisingTechnician: string;
        methodHours: MethodHours[];
      }

      const entriesByDate = new Map<string, Entry>();

      for (const doc of entriesSnapshot.docs) {
        const data = doc.data();
        const entryDate = data.date.toDate();
        const dateKey = `${entryDate.getFullYear()}-${String(entryDate.getMonth() + 1).padStart(2, "0")}-${String(entryDate.getDate()).padStart(2, "0")}`;

        entriesByDate.set(dateKey, {
          date: entryDate,
          location: data.location || "",
          supervisingTechnician: data.supervisingTechnician || "",
          methodHours: data.methodHours || [],
        });
      }

      // Step 5: Fill in the template for each month
      const monthSheets = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

      for (let month = 0; month < 12; month++) {
        const sheetName = monthSheets[month];
        const worksheet = workbook.getWorksheet(sheetName);

        if (!worksheet) {
          logger.warn(`Sheet ${sheetName} not found in template`);
          continue;
        }

        logger.info(`Processing sheet: ${sheetName}`);

        // Get number of days in this month
        const daysInMonth = new Date(year, month + 1, 0).getDate();

        // Data starts at row 7 (ExcelJS uses 1-based indexing)
        // Columns: A=Date(1), B=Location(2), C=MT(3), D=PT(4), E=ET(5),
        //          F=UT(6), G=VT(7), H=LM(8), I=PAUT(9), J=Supervising Tech(10)

        for (let day = 1; day <= daysInMonth; day++) {
          const dateKey = `${year}-${String(month + 1).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
          const entry = entriesByDate.get(dateKey);

          if (!entry) {
            continue; // No entry for this date
          }

          // Row for this day (row 7 is first day, so row = 6 + day)
          const rowIndex = 6 + day;

          // Set Location (Column B)
          worksheet.getCell(rowIndex, 2).value = entry.location;

          // Aggregate hours by method
          const methodTotals: {[key: string]: number} = {};
          for (const mh of entry.methodHours) {
            const method = mh.method.toUpperCase();
            methodTotals[method] = (methodTotals[method] || 0) + mh.hours;
          }

          // Fill in method hours (columns C-I)
          if (methodTotals["MT"]) worksheet.getCell(rowIndex, 3).value = methodTotals["MT"];
          if (methodTotals["PT"]) worksheet.getCell(rowIndex, 4).value = methodTotals["PT"];
          if (methodTotals["ET"]) worksheet.getCell(rowIndex, 5).value = methodTotals["ET"];
          if (methodTotals["UT"]) worksheet.getCell(rowIndex, 6).value = methodTotals["UT"];
          if (methodTotals["VT"]) worksheet.getCell(rowIndex, 7).value = methodTotals["VT"];
          if (methodTotals["LM"]) worksheet.getCell(rowIndex, 8).value = methodTotals["LM"];
          if (methodTotals["PAUT"]) worksheet.getCell(rowIndex, 9).value = methodTotals["PAUT"];

          // Set Supervising Technician (Column J)
          if (entry.supervisingTechnician) {
            worksheet.getCell(rowIndex, 10).value = entry.supervisingTechnician;
          }
        }
      }

      logger.info("All data filled, generating Excel file");

      // Step 6: Save filled Excel to Storage
      const outputBuffer = await workbook.xlsx.writeBuffer();
      const outputFileName = `exports/${userId}/Method_Hours_${year}.xlsx`;
      const outputFile = bucket.file(outputFileName);

      await outputFile.save(Buffer.from(outputBuffer), {
        metadata: {
          contentType: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        },
      });

      logger.info(`File saved to Storage: ${outputFileName}`);

      // Step 7: Generate signed URL (24 hour expiration)
      const [signedUrl] = await outputFile.getSignedUrl({
        action: "read",
        expires: Date.now() + 24 * 60 * 60 * 1000, // 24 hours
      });

      logger.info("Method Hours export completed successfully");

      return {
        success: true,
        downloadUrl: signedUrl,
        fileName: `Method_Hours_${year}.xlsx`,
        entriesCount: entriesSnapshot.docs.length,
      };
    } catch (error) {
      logger.error("Error exporting Method Hours:", error);

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError("internal", `Failed to export Method Hours: ${error}`);
    }
  }
);
