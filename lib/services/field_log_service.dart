import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/field_log_entry.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FieldLogService {
  final CollectionReference _fieldLogsCollection =
      FirebaseFirestore.instance.collection('field_logs');

  // Helper method to convert local date to UTC start of day
  DateTime _toUtcStartOfDay(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  // Helper method to convert local date to UTC end of day
  DateTime _toUtcEndOfDay(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day, 23, 59, 59);
  }

  Future<List<FieldLogEntry>> getEntriesForDate(DateTime date) async {
    try {
      final startOfDay = _toUtcStartOfDay(date);
      final endOfDay = _toUtcEndOfDay(date);
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _fieldLogsCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .get();

      return querySnapshot.docs
          .map((doc) => FieldLogEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting entries for date: $e');
      rethrow;
    }
  }

  Future<List<FieldLogEntry>> getEntriesForDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final utcStartDate = _toUtcStartOfDay(startDate);
      final utcEndDate = _toUtcEndOfDay(endDate);
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _fieldLogsCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: utcStartDate)
          .where('date', isLessThanOrEqualTo: utcEndDate)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => FieldLogEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting entries for date range: $e');
      rethrow;
    }
  }

  Future<FieldLogEntry> addEntry(FieldLogEntry entry) async {
    try {
      // Create a new document reference with an auto-generated ID
      final docRef = _fieldLogsCollection.doc();
      
      // Create a new entry with the generated ID and UTC date
      final newEntry = FieldLogEntry(
        id: docRef.id,
        userId: entry.userId,
        date: entry.date,
        projectName: entry.projectName,
        miles: entry.miles,
        hours: entry.hours,
        methodHours: entry.methodHours,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      print('Attempting to add entry with ID: ${docRef.id}');
      print('Entry data: ${newEntry.toFirestore()}');

      // Set the document with the new entry data
      await docRef.set({
        ...newEntry.toFirestore(),
        'date': Timestamp.fromDate(newEntry.date.toUtc()),
      });
      
      print('Successfully added entry');
      return newEntry;
    } catch (e) {
      print('Error adding entry: $e');
      rethrow;
    }
  }

  Future<void> updateEntry(FieldLogEntry entry) async {
    try {
      final updatedEntry = FieldLogEntry(
        id: entry.id,
        userId: entry.userId,
        date: entry.date,
        projectName: entry.projectName,
        miles: entry.miles,
        hours: entry.hours,
        methodHours: entry.methodHours,
        createdAt: entry.createdAt,
        updatedAt: DateTime.now().toUtc(),
      );
      await _fieldLogsCollection.doc(entry.id).update({
        ...updatedEntry.toFirestore(),
        'date': Timestamp.fromDate(updatedEntry.date.toUtc()),
      });
    } catch (e) {
      print('Error updating entry: $e');
      rethrow;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _fieldLogsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting entry: $e');
      rethrow;
    }
  }

  Stream<List<FieldLogEntry>> getEntriesForMonth(DateTime month) {
    try {
      final startOfMonth = _toUtcStartOfDay(DateTime(month.year, month.month, 1));
      final endOfMonth = _toUtcEndOfDay(DateTime(month.year, month.month + 1, 0));
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      return _fieldLogsCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => FieldLogEntry.fromFirestore(doc)).toList());
    } catch (e) {
      print('Error getting entries for month: $e');
      rethrow;
    }
  }
} 