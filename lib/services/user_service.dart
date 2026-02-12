import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Stream current user profile
  Stream<UserProfile?> getCurrentUserProfileStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  // Create user profile after signup
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    bool acceptedTerms = false,
    bool acceptedPrivacy = false,
  }) async {
    try {
      final userProfile = UserProfile(
        userId: userId,
        email: email,
        displayName: displayName,
        isAdmin: false, // New users are not admin by default
        termsAcceptedAt: acceptedTerms ? DateTime.now() : null,
        privacyAcceptedAt: acceptedPrivacy ? DateTime.now() : null,
        termsVersion: acceptedTerms ? '1.0' : null,
        privacyVersion: acceptedPrivacy ? '1.0' : null,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .set(userProfile.toFirestore());
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .update(profile.toFirestore());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final profile = await getCurrentUserProfile();
    return profile?.isAdmin ?? false;
  }

  // Stream to check if current user is admin
  Stream<bool> isCurrentUserAdminStream() {
    return getCurrentUserProfileStream()
        .map((profile) => profile?.isAdmin ?? false);
  }

  // Get all users (admin only)
  Future<List<UserProfile>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      rethrow;
    }
  }

  // Stream all users (admin only)
  Stream<List<UserProfile>> getAllUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .toList());
  }

  // Toggle user admin status (admin only)
  Future<void> toggleUserAdminStatus(String userId, bool isAdmin) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': isAdmin,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error toggling user admin status: $e');
      rethrow;
    }
  }

  // Search users by email or display name (admin only)
  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('email')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();
      
      return snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      rethrow;
    }
  }

  // Get user by ID (admin only)
  Future<UserProfile?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Delete user profile (admin only - use with caution)
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user profile: $e');
      rethrow;
    }
  }
}
