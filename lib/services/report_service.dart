import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reports';

  /// Add a new report to Firestore
  Future<String> addReport(Report report) async {
    try {
      final docRef = await _firestore.collection(_collection).add(report.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding report: $e');
      rethrow;
    }
  }

  /// Update an existing report in Firestore
  Future<void> updateReport(String reportId, Report report) async {
    try {
      await _firestore.collection(_collection).doc(reportId).update(report.toMap());
    } catch (e) {
      print('Error updating report: $e');
      rethrow;
    }
  }

  /// Delete a report from Firestore
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection(_collection).doc(reportId).delete();
    } catch (e) {
      print('Error deleting report: $e');
      rethrow;
    }
  }

  /// Get a single report by ID
  Future<Report?> getReport(String reportId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(reportId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Report.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting report: $e');
      rethrow;
    }
  }

  /// Get all reports for a specific user
  Future<List<Report>> getUserReports(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Report.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting user reports: $e');
      rethrow;
    }
  }

  /// Get reports stream for real-time updates
  Stream<List<Report>> getUserReportsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Report.fromMap(data);
      }).toList();
    });
  }

  /// Search reports by location or technician name
  Future<List<Report>> searchReports(String userId, String searchTerm) async {
    try {
      final searchTermLower = searchTerm.toLowerCase();
      
      // Get all user reports first, then filter locally
      // Firestore doesn't support case-insensitive search or OR queries easily
      final allReports = await getUserReports(userId);
      
      return allReports.where((report) {
        return report.location.toLowerCase().contains(searchTermLower) ||
               report.technicianName.toLowerCase().contains(searchTermLower) ||
               report.method.toLowerCase().contains(searchTermLower);
      }).toList();
    } catch (e) {
      print('Error searching reports: $e');
      rethrow;
    }
  }

  /// Get reports by date range
  Future<List<Report>> getReportsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('inspectionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('inspectionDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('inspectionDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Report.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting reports by date range: $e');
      rethrow;
    }
  }

  /// Get reports by inspection method
  Future<List<Report>> getReportsByMethod(String userId, String method) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('method', isEqualTo: method)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Report.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting reports by method: $e');
      rethrow;
    }
  }

  /// Get recent reports (last 30 days)
  Future<List<Report>> getRecentReports(String userId, {int days = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffDate))
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Report.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting recent reports: $e');
      rethrow;
    }
  }

  /// Get report statistics for a user
  Future<Map<String, dynamic>> getReportStatistics(String userId) async {
    try {
      final reports = await getUserReports(userId);
      
      final stats = <String, dynamic>{
        'totalReports': reports.length,
        'methodBreakdown': <String, int>{},
        'reportsThisMonth': 0,
        'reportsThisYear': 0,
      };

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);
      final thisYear = DateTime(now.year);

      for (final report in reports) {
        // Method breakdown
        final method = report.method;
        stats['methodBreakdown'][method] = (stats['methodBreakdown'][method] ?? 0) + 1;

        // This month count
        if (report.createdAt.isAfter(thisMonth)) {
          stats['reportsThisMonth']++;
        }

        // This year count
        if (report.createdAt.isAfter(thisYear)) {
          stats['reportsThisYear']++;
        }
      }

      return stats;
    } catch (e) {
      print('Error getting report statistics: $e');
      rethrow;
    }
  }
}
