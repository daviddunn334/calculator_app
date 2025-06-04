import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _reportsCollection;

  ReportService() : _reportsCollection = FirebaseFirestore.instance.collection('reports');

  // Add a new report
  Future<String> addReport(Report report) async {
    try {
      print('Adding report: ${report.toMap()}');
      final docRef = await _reportsCollection.add(report.toMap());
      print('Report added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding report: $e');
      throw Exception('Failed to add report: $e');
    }
  }

  // Get all reports for the current user
  Stream<List<Report>> getReports() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      return _reportsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return Report.fromMap(data);
            }).toList();
          });
    } catch (e) {
      print('Error getting reports: $e');
      throw Exception('Failed to get reports: $e');
    }
  }

  // Get a specific report
  Future<Report?> getReport(String id) async {
    try {
      final doc = await _reportsCollection.doc(id).get();
      if (!doc.exists) {
        return null;
      }
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Report.fromMap(data);
    } catch (e) {
      print('Error getting report: $e');
      throw Exception('Failed to get report: $e');
    }
  }

  // Update a report
  Future<void> updateReport(String id, Report report) async {
    try {
      await _reportsCollection.doc(id).update({
        ...report.toMap(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating report: $e');
      throw Exception('Failed to update report: $e');
    }
  }

  // Delete a report
  Future<void> deleteReport(String id) async {
    try {
      await _reportsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting report: $e');
      throw Exception('Failed to delete report: $e');
    }
  }
} 