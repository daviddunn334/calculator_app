import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/defect_entry.dart';

class DefectService {
  final CollectionReference _defectEntriesCollection =
      FirebaseFirestore.instance.collection('defect_entries');

  // Get all defect entries for the current user, ordered by most recent first
  Stream<List<DefectEntry>> getUserDefectEntries() {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      return _defectEntriesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => DefectEntry.fromFirestore(doc))
              .toList());
    } catch (e) {
      print('Error getting user defect entries: $e');
      rethrow;
    }
  }

  // Get a single defect entry by ID
  Future<DefectEntry?> getDefectEntry(String id) async {
    try {
      final doc = await _defectEntriesCollection.doc(id).get();
      if (!doc.exists) {
        return null;
      }
      return DefectEntry.fromFirestore(doc);
    } catch (e) {
      print('Error getting defect entry: $e');
      rethrow;
    }
  }

  // Add a new defect entry
  Future<DefectEntry> addDefectEntry(DefectEntry entry) async {
    try {
      final docRef = _defectEntriesCollection.doc();
      final now = DateTime.now().toUtc();

      final newEntry = DefectEntry(
        id: docRef.id,
        userId: entry.userId,
        defectType: entry.defectType,
        length: entry.length,
        width: entry.width,
        depth: entry.depth,
        notes: entry.notes,
        clientName: entry.clientName,
        createdAt: now,
        updatedAt: now,
      );

      print('Attempting to add defect entry with ID: ${docRef.id}');
      print('Entry data: ${newEntry.toFirestore()}');

      await docRef.set(newEntry.toFirestore());

      print('Successfully added defect entry');
      return newEntry;
    } catch (e) {
      print('Error adding defect entry: $e');
      rethrow;
    }
  }

  // Update an existing defect entry
  Future<void> updateDefectEntry(DefectEntry entry) async {
    try {
      final updatedEntry = DefectEntry(
        id: entry.id,
        userId: entry.userId,
        defectType: entry.defectType,
        length: entry.length,
        width: entry.width,
        depth: entry.depth,
        notes: entry.notes,
        clientName: entry.clientName,
        createdAt: entry.createdAt,
        updatedAt: DateTime.now().toUtc(),
      );

      await _defectEntriesCollection.doc(entry.id).update(updatedEntry.toFirestore());
      print('Successfully updated defect entry ${entry.id}');
    } catch (e) {
      print('Error updating defect entry: $e');
      rethrow;
    }
  }

  // Delete a defect entry
  Future<void> deleteDefectEntry(String id) async {
    try {
      await _defectEntriesCollection.doc(id).delete();
      print('Successfully deleted defect entry $id');
    } catch (e) {
      print('Error deleting defect entry: $e');
      rethrow;
    }
  }

  // Get defect entries by type for the current user
  Stream<List<DefectEntry>> getDefectEntriesByType(String defectType) {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      return _defectEntriesCollection
          .where('userId', isEqualTo: userId)
          .where('defectType', isEqualTo: defectType)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => DefectEntry.fromFirestore(doc))
              .toList());
    } catch (e) {
      print('Error getting defect entries by type: $e');
      rethrow;
    }
  }

  // Get count of defect entries for the current user
  Future<int> getUserDefectCount() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _defectEntriesCollection
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting defect count: $e');
      rethrow;
    }
  }
}
