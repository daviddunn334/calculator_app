import 'package:cloud_firestore/cloud_firestore.dart';

class MilesEntry {
  final String id;
  final String userId;
  final DateTime date;
  final double miles;
  final double hours;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MilesEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.miles,
    required this.hours,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MilesEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MilesEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      miles: (data['miles'] ?? 0).toDouble(),
      hours: (data['hours'] ?? 0).toDouble(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'miles': miles,
      'hours': hours,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MilesEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? miles,
    double? hours,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MilesEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      miles: miles ?? this.miles,
      hours: hours ?? this.hours,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 