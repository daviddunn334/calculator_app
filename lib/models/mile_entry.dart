import 'package:flutter/foundation.dart';

class MileEntry {
  final String? id;
  final String userId;
  final DateTime date;
  final double miles;
  final String jobSite;
  final String purpose;
  final DateTime createdAt;
  final DateTime updatedAt;

  MileEntry({
    this.id,
    required this.userId,
    required this.date,
    required this.miles,
    required this.jobSite,
    required this.purpose,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory MileEntry.fromMap(Map<String, dynamic> map) {
    if (kDebugMode) {
      print('Creating MileEntry from map: $map');
    }
    
    try {
      return MileEntry(
        id: map['id'] as String?,
        userId: map['user_id'] as String,
        date: DateTime.parse(map['date'] as String),
        miles: (map['miles'] as num).toDouble(),
        jobSite: map['job_site'] as String,
        purpose: map['purpose'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error creating MileEntry from map: $e');
        print('Stack trace: $stackTrace');
        print('Map data: $map');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'date': date.toIso8601String(),
      'miles': miles,
      'job_site': jobSite,
      'purpose': purpose,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (id != null) {
      map['id'] = id!;
    }

    if (kDebugMode) {
      print('Converting MileEntry to map: $map');
    }

    return map;
  }

  MileEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? miles,
    String? jobSite,
    String? purpose,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MileEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      miles: miles ?? this.miles,
      jobSite: jobSite ?? this.jobSite,
      purpose: purpose ?? this.purpose,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 