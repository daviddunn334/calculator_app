import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String email;
  String? displayName;
  String? photoUrl;
  String? bio;
  Map<String, dynamic> preferences;

  UserProfile({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.bio,
    Map<String, dynamic>? preferences,
  }) : preferences = preferences ?? {};

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      userId: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      preferences: data['preferences'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'preferences': preferences,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      userId: userId,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
    );
  }
} 