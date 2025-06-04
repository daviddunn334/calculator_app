import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the user's profile document reference
  DocumentReference get _userProfileRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId);
  }

  // Get the current user's profile
  Stream<UserProfile?> getCurrentProfile() {
    return _userProfileRef.snapshots().map((doc) {
      if (!doc.exists) {
        // Create a default profile if it doesn't exist
        final user = _auth.currentUser;
        if (user != null) {
          final defaultProfile = UserProfile(
            userId: user.uid,
            email: user.email ?? '',
            displayName: user.displayName,
            photoUrl: user.photoURL,
          );
          _userProfileRef.set(defaultProfile.toFirestore());
          return defaultProfile;
        }
        return null;
      }
      return UserProfile.fromFirestore(doc);
    });
  }

  // Update the user's profile
  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _userProfileRef.update(profile.toFirestore());
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Update specific profile fields
  Future<void> updateProfileFields(Map<String, dynamic> fields) async {
    try {
      await _userProfileRef.update({
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating profile fields: $e');
      rethrow;
    }
  }

  // Update user preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      await _userProfileRef.update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating preferences: $e');
      rethrow;
    }
  }
} 