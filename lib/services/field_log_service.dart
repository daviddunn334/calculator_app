import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/field_log_entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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

  Future<List<FieldLogEntry>> getEntriesForDateRange(DateTime startDate, DateTime endDate, {bool forceServerFetch = false}) async {
    try {
      final utcStartDate = _toUtcStartOfDay(startDate);
      final utcEndDate = _toUtcEndOfDay(endDate);
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final query = _fieldLogsCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: utcStartDate)
          .where('date', isLessThanOrEqualTo: utcEndDate)
          .orderBy('date', descending: true);

      // Force fetch from server if requested (bypasses cache)
      final querySnapshot = forceServerFetch
          ? await query.get(const GetOptions(source: Source.server))
          : await query.get();

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
        location: entry.location,
        supervisingTechnician: entry.supervisingTechnician,
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
        location: entry.location,
        supervisingTechnician: entry.supervisingTechnician,
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

  Future<void> exportToExcel(int year) async {
    try {
      // Get all entries for the specified year
      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year, 12, 31, 23, 59, 59);
      final entries = await getEntriesForDateRange(startDate, endDate);
      
      // Sort entries by date (ascending)
      entries.sort((a, b) => a.date.compareTo(b.date));
      
      // Create Excel workbook
      final excel = Excel.createExcel();
      
      // Remove default sheet if exists
      try {
        excel.delete('Sheet1');
      } catch (e) {
        // Ignore if sheet doesn't exist
      }
      
      // Create our sheet
      final sheet = excel['Method Hours $year'];
      
      // Add headers
      final headers = ['Date', 'Location', 'MT', 'PT', 'ET', 'UT', 'VT', 'LM', 'PAUT', 'Supervising Technician', 'Total'];
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = headers[i];
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: '#1b325b',
          fontColorHex: '#FFFFFF',
        );
      }
      
      // Create a map of all dates in the year with entries
      final Map<DateTime, FieldLogEntry> entriesByDate = {};
      for (var entry in entries) {
        final dateKey = DateTime(entry.localDate.year, entry.localDate.month, entry.localDate.day);
        entriesByDate[dateKey] = entry;
      }
      
      // Add all days of the year
      int rowIndex = 1;
      double grandTotal = 0;
      
      for (int month = 1; month <= 12; month++) {
        final daysInMonth = DateTime(year, month + 1, 0).day;
        
        for (int day = 1; day <= daysInMonth; day++) {
          final date = DateTime(year, month, day);
          final entry = entriesByDate[date];
          
          // Date
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
              .value = '${month}/${day}/${year}';
          
          if (entry != null) {
            // Location
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
                .value = entry.location;
            
            // Method hours
            final methodHoursMap = <InspectionMethod, double>{};
            for (var mh in entry.methodHours) {
              methodHoursMap[mh.method] = (methodHoursMap[mh.method] ?? 0) + mh.hours;
            }
            
            double rowTotal = 0;
            
            // MT, PT, ET, UT, VT, LM, PAUT
            final methods = [
              InspectionMethod.mt,
              InspectionMethod.pt,
              InspectionMethod.et,
              InspectionMethod.ut,
              InspectionMethod.vt,
              InspectionMethod.lm,
              InspectionMethod.paut,
            ];
            
            for (var i = 0; i < methods.length; i++) {
              final hours = methodHoursMap[methods[i]] ?? 0;
              if (hours > 0) {
                sheet.cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: rowIndex))
                    .value = hours;
                rowTotal += hours;
              }
            }
            
            // Supervising Technician
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
                .value = entry.supervisingTechnician;
            
            // Total
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
                .value = rowTotal;
            
            grandTotal += rowTotal;
          }
          
          rowIndex++;
        }
      }
      
      // Add grand total row
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = 'TOTAL';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
          .value = grandTotal;
      
      // Style the total row
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
        cell.cellStyle = CellStyle(bold: true);
      }
      
      // Save and share the file
      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Failed to generate Excel file');
      }
      
      if (kIsWeb) {
        // For web, trigger download
        final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Method_Hours_$year.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile/desktop, save and share
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/Method_Hours_$year.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Method Hours $year',
        );
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      rethrow;
    }
  }
}
