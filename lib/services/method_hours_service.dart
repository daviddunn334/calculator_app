import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/method_hours_entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class MethodHoursService {
  final CollectionReference _methodHoursCollection =
      FirebaseFirestore.instance.collection('method_hours');

  // Helper method to normalize date to start of day (no time component)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<List<MethodHoursEntry>> getEntriesForDate(DateTime date) async {
    try {
      final normalizedDate = _normalizeDate(date);
      final startOfDay = Timestamp.fromDate(normalizedDate);
      final endOfDay = Timestamp.fromDate(normalizedDate.add(const Duration(days: 1)));
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('Fetching entries for date: $normalizedDate');
      
      final querySnapshot = await _methodHoursCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .get();

      print('Found ${querySnapshot.docs.length} entries for date');
      
      return querySnapshot.docs
          .map((doc) => MethodHoursEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting entries for date: $e');
      rethrow;
    }
  }

  Future<List<MethodHoursEntry>> getEntriesForDateRange(
    DateTime startDate, 
    DateTime endDate, 
    {bool forceServerFetch = false}
  ) async {
    try {
      final normalizedStart = _normalizeDate(startDate);
      final normalizedEnd = _normalizeDate(endDate).add(const Duration(days: 1));
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('Fetching entries from $normalizedStart to $normalizedEnd');

      final query = _methodHoursCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedStart))
          .where('date', isLessThan: Timestamp.fromDate(normalizedEnd))
          .orderBy('date', descending: true);

      // Force fetch from server if requested (bypasses cache)
      final querySnapshot = forceServerFetch
          ? await query.get(const GetOptions(source: Source.server))
          : await query.get();

      print('Found ${querySnapshot.docs.length} entries in date range');

      return querySnapshot.docs
          .map((doc) => MethodHoursEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting entries for date range: $e');
      rethrow;
    }
  }

  Future<MethodHoursEntry> addEntry(MethodHoursEntry entry) async {
    try {
      // Create a new document reference with an auto-generated ID
      final docRef = _methodHoursCollection.doc();
      
      // Normalize the date to start of day
      final normalizedDate = _normalizeDate(entry.date);
      
      // Create a new entry with the generated ID
      final newEntry = MethodHoursEntry(
        id: docRef.id,
        userId: entry.userId,
        date: normalizedDate,
        location: entry.location,
        supervisingTechnician: entry.supervisingTechnician,
        methodHours: entry.methodHours,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('Attempting to add entry with ID: ${docRef.id}');
      print('Entry data: ${newEntry.toFirestore()}');

      // Set the document with the new entry data
      await docRef.set(newEntry.toFirestore());
      
      print('Successfully added entry');
      return newEntry;
    } catch (e) {
      print('Error adding entry: $e');
      rethrow;
    }
  }

  Future<void> updateEntry(MethodHoursEntry entry) async {
    try {
      final normalizedDate = _normalizeDate(entry.date);
      
      final updatedEntry = MethodHoursEntry(
        id: entry.id,
        userId: entry.userId,
        date: normalizedDate,
        location: entry.location,
        supervisingTechnician: entry.supervisingTechnician,
        methodHours: entry.methodHours,
        createdAt: entry.createdAt,
        updatedAt: DateTime.now(),
      );
      
      print('Updating entry ${entry.id}');
      await _methodHoursCollection.doc(entry.id).update(updatedEntry.toFirestore());
      print('Successfully updated entry');
    } catch (e) {
      print('Error updating entry: $e');
      rethrow;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      print('Deleting entry $id');
      await _methodHoursCollection.doc(id).delete();
      print('Successfully deleted entry');
    } catch (e) {
      print('Error deleting entry: $e');
      rethrow;
    }
  }

  Stream<List<MethodHoursEntry>> getEntriesForMonth(DateTime month) {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      return _methodHoursCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThan: Timestamp.fromDate(endOfMonth.add(const Duration(days: 1))))
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => MethodHoursEntry.fromFirestore(doc)).toList());
    } catch (e) {
      print('Error getting entries for month: $e');
      rethrow;
    }
  }

  Future<void> exportToExcel(int year) async {
    try {
      print('Starting server-side export for year $year');
      
      // Call the Cloud Function to generate the Excel file
      final callable = FirebaseFunctions.instance.httpsCallable('exportMethodHoursToExcel');
      final result = await callable.call({'year': year});
      
      final data = result.data as Map<String, dynamic>;
      final downloadUrl = data['downloadUrl'] as String;
      final fileName = data['fileName'] as String;
      final entriesCount = data['entriesCount'] as int;
      
      print('Cloud Function returned download URL for $entriesCount entries');
      
      // Download the file from the signed URL
      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
      
      final fileBytes = response.bodyBytes;
      print('Downloaded file: ${fileBytes.length} bytes');
      
      if (kIsWeb) {
        // For web, trigger download
        final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        print('File download triggered for web');
      } else {
        // For mobile/desktop, save and share
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Method Hours $year',
        );
        print('File saved and shared: $filePath');
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
