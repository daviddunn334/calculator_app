import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/photo_identification.dart';
import 'performance_service.dart';

/// Service for handling defect photo identification with async processing
class DefectIdentifierService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Uploads a photo to storage for identification
  /// Returns the download URL
  /// Accepts both File (mobile) and XFile (web)
  Future<String> uploadPhotoForIdentification(dynamic photoFile) async {
    // Get file size for performance tracking
    int fileSizeBytes;
    if (kIsWeb) {
      final XFile xFile = photoFile as XFile;
      fileSizeBytes = await xFile.length();
    } else {
      final File file = photoFile as File;
      fileSizeBytes = await file.length();
    }

    return await PerformanceService().trackPhotoUpload<String>(
      fileSizeBytes: fileSizeBytes,
      platform: kIsWeb ? 'web' : 'mobile',
      operation: () async {
        try {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            throw Exception('User not authenticated');
          }

          // Create unique filename with timestamp
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = '$userId-$timestamp.jpg';
          final path = 'defect_photos/$userId/$fileName';

          // Upload file
          final ref = _storage.ref().child(path);
          
          if (kIsWeb) {
            // Web: photoFile is XFile
            final XFile xFile = photoFile as XFile;
            final bytes = await xFile.readAsBytes();
            await ref.putData(bytes);
          } else {
            // Mobile: photoFile is File
            final File file = photoFile as File;
            await ref.putFile(file);
          }

          // Get download URL
          final downloadUrl = await ref.getDownloadURL();
          print('Photo uploaded successfully: $downloadUrl');
          
          return downloadUrl;
        } catch (e) {
          print('Error uploading photo: $e');
          rethrow;
        }
      },
    );
  }

  /// Creates a photo identification document in Firestore
  /// Cloud Function will process it asynchronously
  Future<String> createPhotoIdentification(String photoUrl) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now().toUtc();
      
      // Create document in Firestore
      final docRef = await _firestore.collection('photo_identifications').add({
        'userId': userId,
        'photoUrl': photoUrl,
        'analysisStatus': 'pending',
        'createdAt': Timestamp.fromDate(now),
      });

      print('Photo identification created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating photo identification: $e');
      rethrow;
    }
  }

  /// Complete async workflow: upload photo and create Firestore document
  /// Returns the document ID immediately (doesn't wait for analysis)
  Future<String> processDefectPhoto(dynamic photoFile) async {
    try {
      // Step 1: Upload photo
      final photoUrl = await uploadPhotoForIdentification(photoFile);

      // Step 2: Create Firestore document (returns immediately)
      final docId = await createPhotoIdentification(photoUrl);

      return docId;
    } catch (e) {
      print('Error processing defect photo: $e');
      rethrow;
    }
  }

  /// Get real-time stream of user's photo identifications
  Stream<List<PhotoIdentification>> getPhotoIdentifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('photo_identifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PhotoIdentification.fromFirestore(doc))
          .toList();
    });
  }

  /// Get count of user's photo identifications
  Future<int> getPhotoIdentificationCount() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return 0;

      final snapshot = await _firestore
          .collection('photo_identifications')
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting photo identification count: $e');
      return 0;
    }
  }

  /// Delete a photo identification
  Future<void> deletePhotoIdentification(String id) async {
    try {
      // Get the document to retrieve photo URL
      final doc = await _firestore
          .collection('photo_identifications')
          .doc(id)
          .get();

      if (!doc.exists) {
        throw Exception('Photo identification not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final photoUrl = data['photoUrl'] as String?;

      // Delete from Firestore
      await _firestore.collection('photo_identifications').doc(id).delete();

      // Delete photo from Storage (fire and forget)
      if (photoUrl != null) {
        try {
          final ref = _storage.refFromURL(photoUrl);
          await ref.delete();
          print('Photo deleted from storage: $photoUrl');
        } catch (e) {
          print('Error deleting photo from storage: $e');
          // Don't throw - Firestore delete was successful
        }
      }

      print('Photo identification deleted: $id');
    } catch (e) {
      print('Error deleting photo identification: $e');
      rethrow;
    }
  }
}
