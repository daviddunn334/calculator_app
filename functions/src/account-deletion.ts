/**
 * Account Deletion Cloud Function
 * 
 * Handles complete user account and data deletion for GDPR/CCPA compliance.
 * Deletes all user data from Firestore, Firebase Storage, and Firebase Auth.
 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {getFirestore} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {getAuth} from "firebase-admin/auth";

/**
 * HTTP Callable function to delete user account and all associated data
 * 
 * Security:
 * - Requires authentication
 * - Users can only delete their own account (request.auth.uid validation)
 * 
 * Data Deleted:
 * - Firestore: users, reports, method_hours, personal_folders, personal_locations,
 *              feedback, defect_entries, photo_identifications
 * - Storage: report_images, defect_photos, exports
 * - Auth: Firebase Authentication account
 */
export const deleteUserAccount = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 540, // 9 minutes (max allowed)
    memory: "1GiB",
  },
  async (request) => {
    try {
      // Verify authentication
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "User must be authenticated to delete account.");
      }

      const requestingUserId = request.auth.uid;
      const targetUserId = request.data.userId || requestingUserId;

      // Security check: Users can only delete their own account
      if (requestingUserId !== targetUserId) {
        throw new HttpsError("permission-denied", "You can only delete your own account.");
      }

      logger.info(`Starting account deletion for user: ${targetUserId}`);

      const db = getFirestore();
      const storage = getStorage();
      const auth = getAuth();

      // Track deletion progress
      const deletionStats = {
        reports: 0,
        methodHours: 0,
        personalFolders: 0,
        personalLocations: 0,
        feedback: 0,
        defectEntries: 0,
        photoIdentifications: 0,
        storageFiles: 0,
      };

      // 1. Delete reports collection
      logger.info("Deleting reports...");
      const reportsSnapshot = await db
        .collection("reports")
        .where("userId", "==", targetUserId)
        .get();
      
      const reportBatches = chunkArray(reportsSnapshot.docs, 500);
      for (const batch of reportBatches) {
        const deleteBatch = db.batch();
        batch.forEach((doc) => deleteBatch.delete(doc.ref));
        await deleteBatch.commit();
        deletionStats.reports += batch.length;
      }
      logger.info(`Deleted ${deletionStats.reports} reports`);

      // 2. Delete method_hours collection
      logger.info("Deleting method hours...");
      const methodHoursSnapshot = await db
        .collection("method_hours")
        .where("userId", "==", targetUserId)
        .get();
      
      const methodHoursBatches = chunkArray(methodHoursSnapshot.docs, 500);
      for (const batch of methodHoursBatches) {
        const deleteBatch = db.batch();
        batch.forEach((doc) => deleteBatch.delete(doc.ref));
        await deleteBatch.commit();
        deletionStats.methodHours += batch.length;
      }
      logger.info(`Deleted ${deletionStats.methodHours} method hours entries`);

      // 3. Delete personal_folders collection
      logger.info("Deleting personal folders...");
      const foldersSnapshot = await db
        .collection("personal_folders")
        .where("userId", "==", targetUserId)
        .get();
      
      const folderBatches = chunkArray(foldersSnapshot.docs, 500);
      for (const batch of folderBatches) {
        const deleteBatch = db.batch();
        batch.forEach((doc) => deleteBatch.delete(doc.ref));
        await deleteBatch.commit();
        deletionStats.personalFolders += batch.length;
      }
      logger.info(`Deleted ${deletionStats.personalFolders} personal folders`);

      // 4. Delete personal_locations collection
      logger.info("Deleting personal locations...");
      const locationsSnapshot = await db
        .collection("personal_locations")
        .where("userId", "==", targetUserId)
        .get();
      
      const locationBatches = chunkArray(locationsSnapshot.docs, 500);
      for (const batch of locationBatches) {
        const deleteBatch = db.batch();
        batch.forEach((doc) => deleteBatch.delete(doc.ref));
        await deleteBatch.commit();
        deletionStats.personalLocations += batch.length;
      }
      logger.info(`Deleted ${deletionStats.personalLocations} personal locations`);

      // 5. Delete feedback collection
      logger.info("Deleting feedback...");
      const feedbackSnapshot = await db
        .collection("feedback")
        .where("userId", "==", targetUserId)
        .get();
      
      const feedbackBatches = chunkArray(feedbackSnapshot.docs, 500);
      for (const batch of feedbackBatches) {
        const deleteBatch = db.batch();
        batch.forEach((doc) => deleteBatch.delete(doc.ref));
        await deleteBatch.commit();
        deletionStats.feedback += batch.length;
      }
      logger.info(`Deleted ${deletionStats.feedback} feedback submissions`);

      // 6. Delete defect_entries collection
      logger.info("Deleting defect entries...");
      const defectEntriesSnapshot = await db
        .collection("defect_entries")
        .where("userId", "==", targetUserId)
        .get();
      
      const defectBatches = chunkArray(defectEntriesSnapshot.docs, 500);
      for (const batch of defectBatches) {
        const deleteBatch = db.batch();
        batch.forEach((doc) => deleteBatch.delete(doc.ref));
        await deleteBatch.commit();
        deletionStats.defectEntries += batch.length;
      }
      logger.info(`Deleted ${deletionStats.defectEntries} defect entries`);

      // 7. Delete photo_identifications collection
      logger.info("Deleting photo identifications...");
      const photoIdSnapshot = await db
        .collection("photo_identifications")
        .where("userId", "==", targetUserId)
        .get();
      
      const photoIdBatches = chunkArray(photoIdSnapshot.docs, 500);
      for (const batch of photoIdBatches) {
        const deleteBatch = db.batch();
        batch.forEach((doc) => deleteBatch.delete(doc.ref));
        await deleteBatch.commit();
        deletionStats.photoIdentifications += batch.length;
      }
      logger.info(`Deleted ${deletionStats.photoIdentifications} photo identifications`);

      // 8. Delete Firebase Storage files
      logger.info("Deleting storage files...");
      const bucket = storage.bucket();
      
      // Delete report images
      const reportImagesPath = `report_images/${targetUserId}/`;
      const [reportImages] = await bucket.getFiles({prefix: reportImagesPath});
      for (const file of reportImages) {
        await file.delete();
        deletionStats.storageFiles++;
      }
      logger.info(`Deleted ${reportImages.length} report images`);

      // Delete defect photos
      const defectPhotosPath = `defect_photos/${targetUserId}/`;
      const [defectPhotos] = await bucket.getFiles({prefix: defectPhotosPath});
      for (const file of defectPhotos) {
        await file.delete();
        deletionStats.storageFiles++;
      }
      logger.info(`Deleted ${defectPhotos.length} defect photos`);

      // Delete exports
      const exportsPath = `exports/${targetUserId}/`;
      const [exports] = await bucket.getFiles({prefix: exportsPath});
      for (const file of exports) {
        await file.delete();
        deletionStats.storageFiles++;
      }
      logger.info(`Deleted ${exports.length} export files`);

      // 9. Delete user profile document
      logger.info("Deleting user profile...");
      await db.collection("users").doc(targetUserId).delete();

      // 10. Delete Firebase Auth account (LAST STEP)
      logger.info("Deleting Firebase Auth account...");
      await auth.deleteUser(targetUserId);

      logger.info("Account deletion completed successfully");
      logger.info("Deletion stats:", deletionStats);

      return {
        success: true,
        message: "Account and all associated data deleted successfully",
        stats: deletionStats,
      };
    } catch (error) {
      logger.error("Error during account deletion:", error);

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError("internal", `An error occurred while deleting your account: ${error}`);
    }
  }
);

/**
 * Helper function to chunk array into smaller batches
 * Firestore batch writes are limited to 500 operations
 */
function chunkArray<T>(array: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let i = 0; i < array.length; i += size) {
    chunks.push(array.slice(i, i + size));
  }
  return chunks;
}
