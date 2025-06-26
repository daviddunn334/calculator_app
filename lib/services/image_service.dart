import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  
  // Pick an image from gallery
  Future<XFile?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    return image;
  }
  
  // Take a photo with camera
  Future<XFile?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    return photo;
  }
  
  // Upload image to Firebase Storage and return download URL
  Future<String?> uploadProfileImage(XFile imageFile, String userId) async {
    try {
      // Create a unique filename
      final String fileName = '${userId}_${const Uuid().v4()}';
      final Reference storageRef = _storage.ref().child('profile_images/$fileName');
      
      UploadTask uploadTask;
      
      if (kIsWeb) {
        // Handle web platform
        final bytes = await imageFile.readAsBytes();
        uploadTask = storageRef.putData(bytes);
      } else {
        // Handle mobile platforms
        final File file = File(imageFile.path);
        uploadTask = storageRef.putFile(file);
      }
      
      // Wait for the upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
  
  // Upload report image to Firebase Storage and return download URL
  Future<String?> uploadReportImage(XFile imageFile, String reportId) async {
    try {
      // Create a unique filename
      final String fileName = '${reportId}_${const Uuid().v4()}';
      final Reference storageRef = _storage.ref().child('report_images/$fileName');
      
      UploadTask uploadTask;
      
      if (kIsWeb) {
        // Handle web platform
        final bytes = await imageFile.readAsBytes();
        uploadTask = storageRef.putData(bytes);
      } else {
        // Handle mobile platforms
        final File file = File(imageFile.path);
        uploadTask = storageRef.putFile(file);
      }
      
      // Wait for the upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading report image: $e');
      return null;
    }
  }
  
  // Pick multiple images from gallery
  Future<List<XFile>?> pickMultipleImages() async {
    final List<XFile>? images = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    return images;
  }
  
  // Delete an image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract the path from the URL
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}
