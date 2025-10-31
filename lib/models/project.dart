import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String? id;
  final String divisionId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;

  Project({
    this.id,
    required this.divisionId,
    required this.name,
    this.description,
    DateTime? createdAt,
    this.updatedAt,
    required this.createdBy,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      divisionId: data['divisionId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'divisionId': divisionId,
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    };
  }

  Project copyWith({
    String? name,
    String? description,
  }) {
    return Project(
      id: id,
      divisionId: divisionId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdBy: createdBy,
    );
  }
}
