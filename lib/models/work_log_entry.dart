import 'package:hive/hive.dart';

part 'work_log_entry.g.dart';

@HiveType(typeId: 1)
class WorkLogEntry extends HiveObject {
  @HiveField(0)
  final String digNumber;

  @HiveField(1)
  final String location;

  @HiveField(2)
  final String crew;

  @HiveField(3)
  final double hoursWorked;

  @HiveField(4)
  final String notes;

  @HiveField(5)
  final DateTime timestamp;

  WorkLogEntry({
    required this.digNumber,
    required this.location,
    required this.crew,
    required this.hoursWorked,
    required this.notes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'digNumber': digNumber,
      'location': location,
      'crew': crew,
      'hoursWorked': hoursWorked,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WorkLogEntry.fromJson(Map<String, dynamic> json) {
    return WorkLogEntry(
      digNumber: json['digNumber'],
      location: json['location'],
      crew: json['crew'],
      hoursWorked: json['hoursWorked'],
      notes: json['notes'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
} 