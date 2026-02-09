import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/method_hours_entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:html' as html;
import 'dart:typed_data';

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
      print('Starting export for year $year');
      
      // Load the template from assets
      final ByteData data = await rootBundle.load('assets/templates/method_hours_template.xlsx');
      final Uint8List bytes = data.buffer.asUint8List();
      final excel = Excel.decodeBytes(bytes);
      
      print('Template loaded successfully');
      
      // Get all entries for the specified year
      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year, 12, 31);
      final entries = await getEntriesForDateRange(startDate, endDate);
      
      print('Found ${entries.length} entries for $year');
      
      // Create a map of entries by date for quick lookup
      final Map<DateTime, MethodHoursEntry> entriesByDate = {};
      for (var entry in entries) {
        final dateKey = entry.normalizedDate;
        // If multiple entries for same date, we could aggregate them
        if (entriesByDate.containsKey(dateKey)) {
          // For now, just use the last one. Could be enhanced to merge hours
          print('Warning: Multiple entries found for $dateKey');
        }
        entriesByDate[dateKey] = entry;
      }
      
      // Month name to sheet name mapping
      final monthSheets = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      // Process each month
      for (int month = 1; month <= 12; month++) {
        final sheetName = monthSheets[month - 1];
        final sheet = excel[sheetName];
        
        print('Processing month: $sheetName');
        
        // Data starts at row 7 (row index 6) - first date row
        // Columns: A=Date(0), B=Location(1), C=MT(2), D=PT(3), E=ET(4), 
        //          F=UT(5), G=VT(6), H=LM(7), I=PAUT(8), J=Supervising Tech(9)
        
        final daysInMonth = DateTime(year, month + 1, 0).day;
        
        for (int day = 1; day <= daysInMonth; day++) {
          final date = DateTime(year, month, day);
          final entry = entriesByDate[date];
          
          // Row index: 6 (first date) + (day - 1)
          // Note: day 1 of month might not start at row 6, depends on template
          // Template shows dates starting at row 7 (index 6), but first date might be day 2
          // We need to match by finding the correct row for each day
          final rowIndex = 6 + (day - 1); // Starts at row 7 (index 6)
          
          if (entry != null) {
            // Location (Column B, index 1)
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
                .value = entry.location;
            
            // Aggregate hours by method
            final methodHoursMap = <InspectionMethod, double>{};
            for (var mh in entry.methodHours) {
              methodHoursMap[mh.method] = (methodHoursMap[mh.method] ?? 0) + mh.hours;
            }
            
            // Fill in method hours
            // MT (Column C, index 2)
            final mtHours = methodHoursMap[InspectionMethod.mt] ?? 0;
            if (mtHours > 0) {
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
                  .value = mtHours;
            }
            
            // PT (Column D, index 3)
            final ptHours = methodHoursMap[InspectionMethod.pt] ?? 0;
            if (ptHours > 0) {
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
                  .value = ptHours;
            }
            
            // ET (Column E, index 4)
            final etHours = methodHoursMap[InspectionMethod.et] ?? 0;
            if (etHours > 0) {
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
                  .value = etHours;
            }
            
            // UT (Column F, index 5)
            final utHours = methodHoursMap[InspectionMethod.ut] ?? 0;
            if (utHours > 0) {
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
                  .value = utHours;
            }
            
            // VT (Column G, index 6)
            final vtHours = methodHoursMap[InspectionMethod.vt] ?? 0;
            if (vtHours > 0) {
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
                  .value = vtHours;
            }
            
            // LM (Column H, index 7)
            final lmHours = methodHoursMap[InspectionMethod.lm] ?? 0;
            if (lmHours > 0) {
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
                  .value = lmHours;
            }
            
            // PAUT (Column I, index 8)
            final pautHours = methodHoursMap[InspectionMethod.paut] ?? 0;
            if (pautHours > 0) {
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
                  .value = pautHours;
            }
            
            // Supervising Technician (Column J, index 9)
            if (entry.supervisingTechnician.isNotEmpty) {
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
                  .value = entry.supervisingTechnician;
            }
            
            print('Filled data for $date at row $rowIndex');
          }
        }
      }
      
      print('Data filled successfully, encoding file...');
      
      // Save and share the file
      final exportBytes = excel.encode();
      if (exportBytes == null) {
        throw Exception('Failed to encode Excel file');
      }
      
      if (kIsWeb) {
        // For web, trigger download
        final blob = html.Blob([exportBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Method_Hours_$year.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
        print('File download triggered for web');
      } else {
        // For mobile/desktop, save and share
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/Method_Hours_$year.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(exportBytes);
        
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
