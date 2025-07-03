import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class PdfManagementService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get all companies that have procedure folders
  Future<List<String>> getCompanies() async {
    try {
      final proceduresRef = _storage.ref('procedures');
      final result = await proceduresRef.listAll();

      return result.prefixes.map((prefix) {
        // Extract company name from path
        final pathSegments = prefix.fullPath.split('/');
        return pathSegments.last;
      }).toList();
    } catch (e) {
      print('Error getting companies: $e');
      return [];
    }
  }

  /// Get all PDFs for a specific company
  Future<List<Map<String, dynamic>>> getPdfsForCompany(String company) async {
    try {
      final companyRef = _storage.ref('procedures/$company');
      final result = await companyRef.listAll();

      List<Map<String, dynamic>> pdfs = [];

      for (var item in result.items) {
        try {
          final metadata = await item.getMetadata();
          final downloadUrl = await item.getDownloadURL();

          pdfs.add({
            'name': item.name,
            'fullPath': item.fullPath,
            'downloadUrl': downloadUrl,
            'size': metadata.size,
            'contentType': metadata.contentType,
            'createdAt': metadata.timeCreated,
            'updatedAt': metadata.updated,
            'reference': item,
          });
        } catch (e) {
          print('Error getting metadata for ${item.name}: $e');
          // Add basic info even if metadata fails
          pdfs.add({
            'name': item.name,
            'fullPath': item.fullPath,
            'downloadUrl': await item.getDownloadURL(),
            'size': null,
            'contentType': 'application/pdf',
            'createdAt': null,
            'updatedAt': null,
            'reference': item,
          });
        }
      }

      // Sort by name
      pdfs.sort((a, b) => a['name'].compareTo(b['name']));

      return pdfs;
    } catch (e) {
      print('Error getting PDFs for company $company: $e');
      return [];
    }
  }

  /// Upload a new PDF file
  Future<bool> uploadPdf(String company, PlatformFile file) async {
    try {
      final ref = _storage.ref('procedures/$company/${file.name}');

      if (kIsWeb) {
        // Web upload
        await ref.putData(
          file.bytes!,
          SettableMetadata(
            contentType: 'application/pdf',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          ),
        );
      } else {
        // Mobile/Desktop upload
        final fileToUpload = File(file.path!);
        await ref.putFile(
          fileToUpload,
          SettableMetadata(
            contentType: 'application/pdf',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          ),
        );
      }

      return true;
    } catch (e) {
      print('Error uploading PDF: $e');
      return false;
    }
  }

  /// Delete a PDF file
  Future<bool> deletePdf(String company, String filename) async {
    try {
      final ref = _storage.ref('procedures/$company/$filename');
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting PDF: $e');
      return false;
    }
  }

  /// Replace an existing PDF file
  Future<bool> replacePdf(
      String company, String existingFilename, PlatformFile newFile) async {
    try {
      // Delete the old file first
      await deletePdf(company, existingFilename);

      // Upload the new file with the same name
      final ref = _storage.ref('procedures/$company/$existingFilename');

      if (kIsWeb) {
        await ref.putData(
          newFile.bytes!,
          SettableMetadata(
            contentType: 'application/pdf',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
              'replacedAt': DateTime.now().toIso8601String(),
            },
          ),
        );
      } else {
        final fileToUpload = File(newFile.path!);
        await ref.putFile(
          fileToUpload,
          SettableMetadata(
            contentType: 'application/pdf',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
              'replacedAt': DateTime.now().toIso8601String(),
            },
          ),
        );
      }

      return true;
    } catch (e) {
      print('Error replacing PDF: $e');
      return false;
    }
  }

  /// Rename a PDF file
  Future<bool> renamePdf(
      String company, String oldFilename, String newFilename) async {
    try {
      final oldRef = _storage.ref('procedures/$company/$oldFilename');
      final newRef = _storage.ref('procedures/$company/$newFilename');

      // Download the file data
      final data = await oldRef.getData();
      final metadata = await oldRef.getMetadata();

      // Upload with new name
      await newRef.putData(
        data!,
        SettableMetadata(
          contentType: metadata.contentType,
          customMetadata: {
            ...metadata.customMetadata ?? {},
            'renamedAt': DateTime.now().toIso8601String(),
            'originalName': oldFilename,
          },
        ),
      );

      // Delete the old file
      await oldRef.delete();

      return true;
    } catch (e) {
      print('Error renaming PDF: $e');
      return false;
    }
  }

  /// Create a new company folder
  Future<bool> createCompanyFolder(String company) async {
    try {
      // Create a placeholder file to ensure the folder exists
      final ref = _storage.ref('procedures/$company/.placeholder');
      await ref
          .putString('This folder contains procedure documents for $company');
      return true;
    } catch (e) {
      print('Error creating company folder: $e');
      return false;
    }
  }

  /// Get file size in human readable format
  String formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown size';

    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Check if file is a PDF
  bool isPdfFile(String filename) {
    return filename.toLowerCase().endsWith('.pdf');
  }

  /// Get download URL for a PDF
  Future<String> getDownloadUrl(String company, String filename) async {
    try {
      final ref = _storage.ref('procedures/$company/$filename');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      rethrow;
    }
  }
}
