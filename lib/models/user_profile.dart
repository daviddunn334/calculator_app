import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String email;
  String? displayName;
  String? photoUrl;
  String? bio;
  Map<String, dynamic> preferences;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.bio,
    Map<String, dynamic>? preferences,
    this.isAdmin = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : preferences = preferences ?? {},
       createdAt = createdAt ?? DateTime.now();

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      userId: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      preferences: data['preferences'] ?? {},
      isAdmin: data['isAdmin'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'preferences': preferences,
      'isAdmin': isAdmin,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    Map<String, dynamic>? preferences,
    bool? isAdmin,
  }) {
    return UserProfile(
      userId: userId,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
