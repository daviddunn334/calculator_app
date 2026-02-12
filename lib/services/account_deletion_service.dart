import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/analytics_service.dart';

/// Service for handling user account deletion
/// Implements GDPR "Right to be Forgotten" and CCPA compliance
class AccountDeletionService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AnalyticsService _analytics = AnalyticsService();

  /// Delete the current user's account and all associated data
  /// 
  /// This will:
  /// - Delete all Firestore collections (reports, method_hours, personal_folders, etc.)
  /// - Delete all Firebase Storage files (photos, exports)
  /// - Delete the user profile
  /// - Delete the Firebase Auth account
  /// 
  /// Returns a map with deletion statistics or throws an error
  Future<Map<String, dynamic>> deleteCurrentUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      // Log analytics event before deletion
      await _analytics.logEvent(
        name: 'account_deletion_initiated',
        parameters: {
          'user_id': user.uid,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Call Cloud Function to delete all user data
      final callable = _functions.httpsCallable('deleteUserAccount');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': user.uid,
      });

      if (result.data['success'] == true) {
        // Log successful deletion (this will be the last event for this user)
        await _analytics.logEvent(
          name: 'account_deleted',
          parameters: {
            'user_id': user.uid,
            'stats': result.data['stats']?.toString() ?? 'unknown',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        return result.data;
      } else {
        throw Exception(result.data['message'] ?? 'Account deletion failed');
      }
    } catch (e) {
      // Log failure
      await _analytics.logError(
        errorMessage: 'Account deletion failed: $e',
        screen: 'AccountDeletionService',
        stackTrace: StackTrace.current.toString(),
      );
      
      print('Error deleting account: $e');
      rethrow;
    }
  }

  /// Re-authenticate the user with their password
  /// Required before account deletion for security
  Future<bool> reauthenticateUser(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      // Create credential with email and password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      // Re-authenticate
      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Incorrect password. Please try again.');
      } else if (e.code == 'user-mismatch') {
        throw Exception('Credential does not match the current user.');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Invalid credential. Please try again.');
      } else {
        throw Exception('Re-authentication failed: ${e.message}');
      }
    } catch (e) {
      print('Error re-authenticating user: $e');
      throw Exception('Re-authentication failed. Please try again.');
    }
  }
}
