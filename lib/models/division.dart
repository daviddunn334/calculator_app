import 'package:cloud_firestore/cloud_firestore.dart';

class Division {
  final String? id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;

  Division({
    this.id,
    required this.name,
    this.description,
    DateTime? createdAt,
    this.updatedAt,
    required this.createdBy,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Division.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Division(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    };
  }

  Division copyWith({
    String? name,
    String? description,
  }) {
    return Division(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdBy: createdBy,
    );
  }
}
