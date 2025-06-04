import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mile_entry.dart';

class MileTrackerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the miles collection reference
  CollectionReference<Map<String, dynamic>> get _milesCollection {
    print('Getting miles collection');
    return _firestore.collection('miles');
  }

  // Test method to verify data storage
  Future<void> testDataStorage() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        throw Exception('User not authenticated');
      }
      print('Testing data storage for user: ${_auth.currentUser?.email}');
      print('User ID: $userId');

      // Create a test entry
      final testEntry = {
        'userId': userId,
        'date': DateTime.now().toIso8601String(),
        'miles': 10.0,
        'hours': 2.0,
        'job_site': 'Test Site',
        'purpose': 'Test Purpose',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add the test entry
      final docRef = await _milesCollection.add(testEntry);
      print('Test entry added with ID: ${docRef.id}');

      // Verify the entry was added
      final doc = await docRef.get();
      print('Retrieved test entry: ${doc.data()}');

      // Query for the entry
      final querySnapshot = await _milesCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      print('Found ${querySnapshot.docs.length} entries for user');
      for (var doc in querySnapshot.docs) {
        print('Entry data: ${doc.data()}');
      }

      // Delete the test entry
      await docRef.delete();
      print('Test entry deleted');
    } catch (e) {
      print('Error in test data storage: $e');
      throw Exception('Failed to test data storage: $e');
    }
  }

  // Get all mile entries for the current user as a stream
  Stream<List<MileEntry>> getMileEntries() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        throw Exception('User not authenticated');
      }
      print('Getting miles for user: $userId');
      print('Current user email: ${_auth.currentUser?.email}');
      
      return _milesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            print('Received ${snapshot.docs.length} mile entries');
            print('Query path: ${snapshot.docs.firstOrNull?.reference.parent.path}');
            return snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              print('Entry data: $data');
              print('Entry user ID: ${data['userId']}');
              print('Current user ID: $userId');
              return MileEntry.fromMap(data);
            }).toList();
          });
    } catch (e) {
      print('Error getting mile entries: $e');
      throw Exception('Failed to get mile entries: $e');
    }
  }

  // Get a specific mile entry for a date
  Future<MileEntry?> getMileEntryForDate(DateTime date) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        throw Exception('User not authenticated');
      }
      print('Getting entry for date: $date');
      print('Current user: ${_auth.currentUser?.email}');
      print('Current user ID: $userId');

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _milesCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      if (snapshot.docs.isEmpty) {
        print('No entry found for date: $date');
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      print('Found entry: $data');
      print('Entry user ID: ${data['userId']}');
      return MileEntry.fromMap(data);
    } catch (e) {
      print('Error getting mile entry for date: $e');
      throw Exception('Failed to get mile entry: $e');
    }
  }

  // Add a new mile entry
  Future<MileEntry> addMileEntry(MileEntry entry) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        throw Exception('User not authenticated');
      }
      print('Adding mile entry for user: ${_auth.currentUser?.email}');
      print('User ID: $userId');
      print('Entry data: ${entry.toMap()}');

      final entryData = {
        ...entry.toMap(),
        'userId': userId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      print('Final entry data: $entryData');

      final docRef = await _milesCollection.add(entryData);
      print('Mile entry added successfully with ID: ${docRef.id}');
      print('Collection path: ${docRef.parent.path}');

      // Verify the entry was added correctly
      final doc = await docRef.get();
      print('Retrieved added entry: ${doc.data()}');
      
      return entry.copyWith(id: docRef.id);
    } catch (e) {
      print('Error adding mile entry: $e');
      throw Exception('Failed to add mile entry: $e');
    }
  }

  // Update an existing mile entry
  Future<void> updateMileEntry(MileEntry entry) async {
    try {
      if (entry.id == null) {
        print('Error: Entry ID is required for update');
        throw Exception('Entry ID is required for update');
      }
      print('Updating mile entry for user: ${_auth.currentUser?.email}');
      print('User ID: ${_auth.currentUser?.uid}');
      print('Entry data: ${entry.toMap()}');

      final updateData = {
        ...entry.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      print('Final update data: $updateData');

      await _milesCollection.doc(entry.id).update(updateData);
      print('Mile entry updated successfully');

      // Verify the update
      final doc = await _milesCollection.doc(entry.id).get();
      print('Retrieved updated entry: ${doc.data()}');
    } catch (e) {
      print('Error updating mile entry: $e');
      throw Exception('Failed to update mile entry: $e');
    }
  }

  // Delete a mile entry
  Future<void> deleteMileEntry(String id) async {
    try {
      print('Deleting mile entry for user: ${_auth.currentUser?.email}');
      print('User ID: ${_auth.currentUser?.uid}');
      print('Entry ID: $id');

      // Verify the entry before deleting
      final doc = await _milesCollection.doc(id).get();
      print('Entry to delete: ${doc.data()}');

      await _milesCollection.doc(id).delete();
      print('Mile entry deleted successfully');
    } catch (e) {
      print('Error deleting mile entry: $e');
      throw Exception('Failed to delete mile entry: $e');
    }
  }

  // Get daily totals for the current user
  Stream<List<Map<String, dynamic>>> getDailyTotals() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        throw Exception('User not authenticated');
      }
      print('Getting daily totals for user: ${_auth.currentUser?.email}');
      print('User ID: $userId');
      
      return _milesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            print('Received ${snapshot.docs.length} entries for daily totals');
            final Map<String, Map<String, dynamic>> dailyTotals = {};
            
            for (var doc in snapshot.docs) {
              final data = doc.data();
              print('Processing entry: $data');
              print('Entry user ID: ${data['userId']}');
              final date = DateTime.parse(data['date'] as String);
              final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              
              if (!dailyTotals.containsKey(dateKey)) {
                dailyTotals[dateKey] = {
                  'date': date,
                  'total_miles': 0.0,
                  'total_hours': 0.0,
                  'entries': 0,
                };
              }

              final entry = dailyTotals[dateKey]!;
              entry['total_miles'] = (entry['total_miles'] as double) + (data['miles'] as num).toDouble();
              entry['total_hours'] = (entry['total_hours'] as double) + (data['hours'] as num).toDouble();
              entry['entries'] = (entry['entries'] as int) + 1;
            }

            return dailyTotals.values.toList();
          });
    } catch (e) {
      print('Error getting daily totals: $e');
      throw Exception('Failed to get daily totals: $e');
    }
  }

  // Get monthly totals for the current user
  Stream<List<Map<String, dynamic>>> getMonthlyTotals() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        throw Exception('User not authenticated');
      }
      print('Getting monthly totals for user: ${_auth.currentUser?.email}');
      print('User ID: $userId');
      
      return _milesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            print('Received ${snapshot.docs.length} entries for monthly totals');
            final Map<String, Map<String, dynamic>> monthlyTotals = {};
            
            for (var doc in snapshot.docs) {
              final data = doc.data();
              print('Processing entry: $data');
              print('Entry user ID: ${data['userId']}');
              final date = DateTime.parse(data['date'] as String);
              final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
              
              if (!monthlyTotals.containsKey(monthKey)) {
                monthlyTotals[monthKey] = {
                  'year': date.year,
                  'month': date.month,
                  'total_miles': 0.0,
                  'total_hours': 0.0,
                  'entries': 0,
                };
              }

              final entry = monthlyTotals[monthKey]!;
              entry['total_miles'] = (entry['total_miles'] as double) + (data['miles'] as num).toDouble();
              entry['total_hours'] = (entry['total_hours'] as double) + (data['hours'] as num).toDouble();
              entry['entries'] = (entry['entries'] as int) + 1;
            }

            return monthlyTotals.values.toList();
          });
    } catch (e) {
      print('Error getting monthly totals: $e');
      throw Exception('Failed to get monthly totals: $e');
    }
  }
} 