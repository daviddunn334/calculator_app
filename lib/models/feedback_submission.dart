import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum FeedbackType {
  bug,
  feature,
  general,
}

enum FeedbackStatus {
  newSubmission,
  inReview,
  resolved,
}

class FeedbackSubmission {
  final String? id;
  final String userId;
  final String userName;
  final String userEmail;
  final FeedbackType type;
  final String subject;
  final String description;
  final String? screenshotUrl;
  final Map<String, dynamic> deviceInfo;
  final DateTime timestamp;
  final FeedbackStatus status;

  const FeedbackSubmission({
    this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.type,
    required this.subject,
    required this.description,
    this.screenshotUrl,
    required this.deviceInfo,
    required this.timestamp,
    this.status = FeedbackStatus.newSubmission,
  });

  // Create from Firestore document
  factory FeedbackSubmission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FeedbackSubmission(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      type: FeedbackType.values.firstWhere(
        (e) => e.toString() == 'FeedbackType.${data['type']}',
        orElse: () => FeedbackType.general,
      ),
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      screenshotUrl: data['screenshotUrl'],
      deviceInfo: Map<String, dynamic>.from(data['deviceInfo'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: FeedbackStatus.values.firstWhere(
        (e) => e.toString() == 'FeedbackStatus.${data['status']}',
        orElse: () => FeedbackStatus.newSubmission,
      ),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'type': type.name,
      'subject': subject,
      'description': description,
      'screenshotUrl': screenshotUrl,
      'deviceInfo': deviceInfo,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status.name,
    };
  }

  // Copy with method for updates
  FeedbackSubmission copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    FeedbackType? type,
    String? subject,
    String? description,
    String? screenshotUrl,
    Map<String, dynamic>? deviceInfo,
    DateTime? timestamp,
    FeedbackStatus? status,
  }) {
    return FeedbackSubmission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      screenshotUrl: screenshotUrl ?? this.screenshotUrl,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}

// Extension methods for type helpers
extension FeedbackTypeExtension on FeedbackType {
  String get displayName {
    switch (this) {
      case FeedbackType.bug:
        return 'Bug Report';
      case FeedbackType.feature:
        return 'Feature Request';
      case FeedbackType.general:
        return 'General Feedback';
    }
  }

  IconData get icon {
    switch (this) {
      case FeedbackType.bug:
        return Icons.bug_report;
      case FeedbackType.feature:
        return Icons.lightbulb;
      case FeedbackType.general:
        return Icons.feedback;
    }
  }

  Color get color {
    switch (this) {
      case FeedbackType.bug:
        return const Color(0xFFF44336); // Red
      case FeedbackType.feature:
        return const Color(0xFF2196F3); // Blue
      case FeedbackType.general:
        return const Color(0xFF4CAF50); // Green
    }
  }
}

extension FeedbackStatusExtension on FeedbackStatus {
  String get displayName {
    switch (this) {
      case FeedbackStatus.newSubmission:
        return 'New';
      case FeedbackStatus.inReview:
        return 'In Review';
      case FeedbackStatus.resolved:
        return 'Resolved';
    }
  }

  Color get color {
    switch (this) {
      case FeedbackStatus.newSubmission:
        return const Color(0xFFFF9800); // Orange
      case FeedbackStatus.inReview:
        return const Color(0xFF2196F3); // Blue
      case FeedbackStatus.resolved:
        return const Color(0xFF4CAF50); // Green
    }
  }
}
