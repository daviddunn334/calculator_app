import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/work_log_entry.dart';

class WorkLogService {
  static const String _boxName = 'workLogs';
  late Box<WorkLogEntry> _box;

  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(WorkLogEntryAdapter());
    _box = await Hive.openBox<WorkLogEntry>(_boxName);
  }

  Future<void> addEntry(WorkLogEntry entry) async {
    await _box.add(entry);
  }

  Future<void> updateEntry(int index, WorkLogEntry entry) async {
    await _box.putAt(index, entry);
  }

  Future<void> deleteEntry(int index) async {
    await _box.deleteAt(index);
  }

  List<WorkLogEntry> getAllEntries() {
    return _box.values.toList();
  }

  Future<String> exportToCsv() async {
    final entries = getAllEntries();
    final csvData = StringBuffer();
    
    // Add headers
    csvData.writeln('Dig #,Location,Crew,Hours Worked,Notes,Timestamp');
    
    // Add entries
    for (var entry in entries) {
      csvData.writeln([
        entry.digNumber,
        entry.location,
        entry.crew,
        entry.hoursWorked.toString(),
        entry.notes,
        entry.timestamp.toIso8601String(),
      ].join(','));
    }
    
    return csvData.toString();
  }

  Future<String> exportToPdf() async {
    final entries = getAllEntries();
    final pdfData = StringBuffer();
    
    // Add title
    pdfData.writeln('Daily Work Log Report');
    pdfData.writeln('Generated on: ${DateTime.now().toString()}');
    pdfData.writeln('\n');
    
    // Add entries
    for (var entry in entries) {
      pdfData.writeln('Dig #: ${entry.digNumber}');
      pdfData.writeln('Location: ${entry.location}');
      pdfData.writeln('Crew: ${entry.crew}');
      pdfData.writeln('Hours Worked: ${entry.hoursWorked}');
      pdfData.writeln('Notes: ${entry.notes}');
      pdfData.writeln('Timestamp: ${entry.timestamp.toString()}');
      pdfData.writeln('----------------------------------------');
    }
    
    return pdfData.toString();
  }
} 