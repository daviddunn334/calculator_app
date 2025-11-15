import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalFolder {
  final String? id;
  final String userId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PersonalFolder({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PersonalFolder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PersonalFolder(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  PersonalFolder copyWith({
    String? name,
    String? description,
  }) {
    return PersonalFolder(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
