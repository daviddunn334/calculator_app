import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/feedback_submission.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection reference
  CollectionReference get _feedbackCollection => _firestore.collection('feedback');

  // Get current user info
  String get _currentUserId => _auth.currentUser?.uid ?? 'anonymous';
  String get _currentUserName => _auth.currentUser?.displayName ?? 'Unknown User';
  String get _currentUserEmail => _auth.currentUser?.email ?? '';

  // Get device info
  Map<String, dynamic> getDeviceInfo() {
    final Map<String, dynamic> deviceInfo = {};
    
    if (kIsWeb) {
      deviceInfo['platform'] = 'Web';
      deviceInfo['userAgent'] = 'Browser';
    } else if (Platform.isAndroid) {
      deviceInfo['platform'] = 'Android';
      deviceInfo['osVersion'] = Platform.operatingSystemVersion;
    } else if (Platform.isIOS) {
      deviceInfo['platform'] = 'iOS';
      deviceInfo['osVersion'] = Platform.operatingSystemVersion;
    } else if (Platform.isWindows) {
      deviceInfo['platform'] = 'Windows';
      deviceInfo['osVersion'] = Platform.operatingSystemVersion;
    } else if (Platform.isMacOS) {
      deviceInfo['platform'] = 'macOS';
      deviceInfo['osVersion'] = Platform.operatingSystemVersion;
    } else if (Platform.isLinux) {
      deviceInfo['platform'] = 'Linux';
      deviceInfo['osVersion'] = Platform.operatingSystemVersion;
    } else {
      deviceInfo['platform'] = 'Unknown';
    }
    
    deviceInfo['timestamp'] = DateTime.now().toIso8601String();
    
    return deviceInfo;
  }

  // Submit feedback
  Future<String?> submitFeedback(FeedbackSubmission feedback) async {
    try {
      final docRef = await _feedbackCollection.add(feedback.toFirestore());
      print('Feedback submitted successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error submitting feedback: $e');
      return null;
    }
  }

  // Upload screenshot to Firebase Storage
  Future<String?> uploadScreenshot(File file) async {
    try {
      final String fileName = 'feedback_screenshots/${_currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(fileName);
      
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Screenshot uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading screenshot: $e');
      return null;
    }
  }

  // Stream of all feedback (for admin)
  Stream<List<FeedbackSubmission>> getAllFeedback({
    FeedbackType? type,
    FeedbackStatus? status,
  }) {
    Query query = _feedbackCollection.orderBy('timestamp', descending: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FeedbackSubmission.fromFirestore(doc))
          .toList();
    });
  }

  // Get feedback by user ID
  Stream<List<FeedbackSubmission>> getUserFeedback(String userId) {
    return _feedbackCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FeedbackSubmission.fromFirestore(doc))
          .toList();
    });
  }

  // Get single feedback by ID
  Future<FeedbackSubmission?> getFeedbackById(String id) async {
    try {
      final doc = await _feedbackCollection.doc(id).get();
      if (doc.exists) {
        return FeedbackSubmission.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting feedback by ID: $e');
      return null;
    }
  }

  // Update feedback status
  Future<bool> updateStatus(String id, FeedbackStatus status) async {
    try {
      await _feedbackCollection.doc(id).update({
        'status': status.name,
      });
      print('Feedback status updated: $id -> ${status.name}');
      return true;
    } catch (e) {
      print('Error updating feedback status: $e');
      return false;
    }
  }

  // Delete feedback
  Future<bool> deleteFeedback(String id) async {
    try {
      await _feedbackCollection.doc(id).delete();
      print('Feedback deleted: $id');
      return true;
    } catch (e) {
      print('Error deleting feedback: $e');
      return false;
    }
  }

  // Get feedback count by status
  Future<Map<FeedbackStatus, int>> getFeedbackCountByStatus() async {
    try {
      final snapshot = await _feedbackCollection.get();
      final Map<FeedbackStatus, int> counts = {
        FeedbackStatus.newSubmission: 0,
        FeedbackStatus.inReview: 0,
        FeedbackStatus.resolved: 0,
      };

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = FeedbackStatus.values.firstWhere(
          (e) => e.toString() == 'FeedbackStatus.${data['status']}',
          orElse: () => FeedbackStatus.newSubmission,
        );
        counts[status] = (counts[status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Error getting feedback count by status: $e');
      return {};
    }
  }

  // Get feedback count by type
  Future<Map<FeedbackType, int>> getFeedbackCountByType() async {
    try {
      final snapshot = await _feedbackCollection.get();
      final Map<FeedbackType, int> counts = {
        FeedbackType.bug: 0,
        FeedbackType.feature: 0,
        FeedbackType.general: 0,
      };

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final type = FeedbackType.values.firstWhere(
          (e) => e.toString() == 'FeedbackType.${data['type']}',
          orElse: () => FeedbackType.general,
        );
        counts[type] = (counts[type] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Error getting feedback count by type: $e');
      return {};
    }
  }

  // Search feedback
  Future<List<FeedbackSubmission>> searchFeedback(String query) async {
    try {
      final snapshot = await _feedbackCollection.get();
      final feedbacks = snapshot.docs
          .map((doc) => FeedbackSubmission.fromFirestore(doc))
          .toList();

      // Filter by search query (client-side since Firestore doesn't support full-text search)
      final searchQuery = query.toLowerCase();
      return feedbacks.where((feedback) {
        return feedback.subject.toLowerCase().contains(searchQuery) ||
               feedback.description.toLowerCase().contains(searchQuery) ||
               feedback.userName.toLowerCase().contains(searchQuery) ||
               feedback.userEmail.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      print('Error searching feedback: $e');
      return [];
    }
  }

  // Get recent feedback (for dashboard)
  Future<List<FeedbackSubmission>> getRecentFeedback({int limit = 5}) async {
    try {
      final snapshot = await _feedbackCollection
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackSubmission.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting recent feedback: $e');
      return [];
    }
  }
}
