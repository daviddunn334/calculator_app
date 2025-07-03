import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum NewsCategory {
  company,
  industry,
  protocol,
  training,
}

enum NewsPriority {
  low,
  normal,
  high,
  urgent,
}

enum NewsType {
  alert,      // Short alerts like certification reminders
  newsletter, // Monthly newsletters with articles/links
  announcement, // General announcements
  update,     // Regular updates
}

class NewsUpdate {
  final String? id;
  final String title;
  final String description;
  final DateTime createdDate;
  final DateTime? publishDate;
  final DateTime? expirationDate;
  final NewsCategory category;
  final NewsPriority priority;
  final NewsType type;
  final IconData icon;
  final String iconName; // Store icon name for Firebase
  final bool isPublished;
  final bool isDraft;
  final String authorId;
  final String? authorName;
  final List<String> links;
  final List<String> imageUrls;
  final Map<String, dynamic>? metadata;
  final int viewCount;
  final DateTime lastModified;

  const NewsUpdate({
    this.id,
    required this.title,
    required this.description,
    required this.createdDate,
    this.publishDate,
    this.expirationDate,
    required this.category,
    this.priority = NewsPriority.normal,
    this.type = NewsType.update,
    required this.icon,
    required this.iconName,
    this.isPublished = false,
    this.isDraft = true,
    required this.authorId,
    this.authorName,
    this.links = const [],
    this.imageUrls = const [],
    this.metadata,
    this.viewCount = 0,
    required this.lastModified,
  });

  // Create from Firestore document
  factory NewsUpdate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NewsUpdate(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      publishDate: data['publishDate'] != null 
          ? (data['publishDate'] as Timestamp).toDate() 
          : null,
      expirationDate: data['expirationDate'] != null 
          ? (data['expirationDate'] as Timestamp).toDate() 
          : null,
      category: NewsCategory.values.firstWhere(
        (e) => e.toString() == 'NewsCategory.${data['category']}',
        orElse: () => NewsCategory.company,
      ),
      priority: NewsPriority.values.firstWhere(
        (e) => e.toString() == 'NewsPriority.${data['priority']}',
        orElse: () => NewsPriority.normal,
      ),
      type: NewsType.values.firstWhere(
        (e) => e.toString() == 'NewsType.${data['type']}',
        orElse: () => NewsType.update,
      ),
      icon: _getIconFromName(data['iconName'] ?? 'info'),
      iconName: data['iconName'] ?? 'info',
      isPublished: data['isPublished'] ?? false,
      isDraft: data['isDraft'] ?? true,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'],
      links: List<String>.from(data['links'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      metadata: data['metadata'],
      viewCount: data['viewCount'] ?? 0,
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdDate': Timestamp.fromDate(createdDate),
      'publishDate': publishDate != null ? Timestamp.fromDate(publishDate!) : null,
      'expirationDate': expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
      'category': category.name,
      'priority': priority.name,
      'type': type.name,
      'iconName': iconName,
      'isPublished': isPublished,
      'isDraft': isDraft,
      'authorId': authorId,
      'authorName': authorName,
      'links': links,
      'imageUrls': imageUrls,
      'metadata': metadata,
      'viewCount': viewCount,
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }

  // Copy with method for updates
  NewsUpdate copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdDate,
    DateTime? publishDate,
    DateTime? expirationDate,
    NewsCategory? category,
    NewsPriority? priority,
    NewsType? type,
    IconData? icon,
    String? iconName,
    bool? isPublished,
    bool? isDraft,
    String? authorId,
    String? authorName,
    List<String>? links,
    List<String>? imageUrls,
    Map<String, dynamic>? metadata,
    int? viewCount,
    DateTime? lastModified,
  }) {
    return NewsUpdate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      publishDate: publishDate ?? this.publishDate,
      expirationDate: expirationDate ?? this.expirationDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      iconName: iconName ?? this.iconName,
      isPublished: isPublished ?? this.isPublished,
      isDraft: isDraft ?? this.isDraft,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      links: links ?? this.links,
      imageUrls: imageUrls ?? this.imageUrls,
      metadata: metadata ?? this.metadata,
      viewCount: viewCount ?? this.viewCount,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  // Helper method to get icon from name
  static IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school;
      case 'new_releases':
        return Icons.new_releases;
      case 'business':
        return Icons.business;
      case 'celebration':
        return Icons.celebration;
      case 'warning':
        return Icons.warning;
      case 'notification_important':
        return Icons.notification_important;
      case 'article':
        return Icons.article;
      case 'link':
        return Icons.link;
      case 'build_circle':
        return Icons.build_circle;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'groups':
        return Icons.groups;
      case 'card_membership':
        return Icons.card_membership;
      case 'computer':
        return Icons.computer;
      case 'campaign':
        return Icons.campaign;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  // Get available icons for admin panel
  static List<Map<String, dynamic>> getAvailableIcons() {
    return [
      {'name': 'info', 'icon': Icons.info, 'label': 'Info'},
      {'name': 'school', 'icon': Icons.school, 'label': 'Training'},
      {'name': 'new_releases', 'icon': Icons.new_releases, 'label': 'New Release'},
      {'name': 'business', 'icon': Icons.business, 'label': 'Business'},
      {'name': 'celebration', 'icon': Icons.celebration, 'label': 'Celebration'},
      {'name': 'warning', 'icon': Icons.warning, 'label': 'Warning'},
      {'name': 'notification_important', 'icon': Icons.notification_important, 'label': 'Important'},
      {'name': 'article', 'icon': Icons.article, 'label': 'Article'},
      {'name': 'link', 'icon': Icons.link, 'label': 'Link'},
      {'name': 'build_circle', 'icon': Icons.build_circle, 'label': 'Equipment'},
      {'name': 'health_and_safety', 'icon': Icons.health_and_safety, 'label': 'Safety'},
      {'name': 'groups', 'icon': Icons.groups, 'label': 'Team'},
      {'name': 'card_membership', 'icon': Icons.card_membership, 'label': 'Certification'},
      {'name': 'computer', 'icon': Icons.computer, 'label': 'Technology'},
      {'name': 'campaign', 'icon': Icons.campaign, 'label': 'Announcement'},
      {'name': 'schedule', 'icon': Icons.schedule, 'label': 'Schedule'},
    ];
  }

  // Check if update is currently active
  bool get isActive {
    final now = DateTime.now();
    if (!isPublished) return false;
    if (publishDate != null && publishDate!.isAfter(now)) return false;
    if (expirationDate != null && expirationDate!.isBefore(now)) return false;
    return true;
  }

  // Check if update is expired
  bool get isExpired {
    if (expirationDate == null) return false;
    return expirationDate!.isBefore(DateTime.now());
  }

  // Check if update is scheduled for future
  bool get isScheduled {
    if (publishDate == null) return false;
    return publishDate!.isAfter(DateTime.now());
  }
}

// Extension methods for category helpers
extension NewsCategoryExtension on NewsCategory {
  String get displayName {
    switch (this) {
      case NewsCategory.company:
        return 'Company';
      case NewsCategory.industry:
        return 'Industry';
      case NewsCategory.protocol:
        return 'Protocol';
      case NewsCategory.training:
        return 'Training';
    }
  }

  Color get color {
    switch (this) {
      case NewsCategory.company:
        return const Color(0xFF2196F3); // Blue
      case NewsCategory.industry:
        return const Color(0xFF4CAF50); // Green
      case NewsCategory.protocol:
        return const Color(0xFFFF9800); // Orange
      case NewsCategory.training:
        return const Color(0xFF9C27B0); // Purple
    }
  }
}

extension NewsPriorityExtension on NewsPriority {
  String get displayName {
    switch (this) {
      case NewsPriority.low:
        return 'Low';
      case NewsPriority.normal:
        return 'Normal';
      case NewsPriority.high:
        return 'High';
      case NewsPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case NewsPriority.low:
        return const Color(0xFF9E9E9E); // Grey
      case NewsPriority.normal:
        return const Color(0xFF2196F3); // Blue
      case NewsPriority.high:
        return const Color(0xFFFF9800); // Orange
      case NewsPriority.urgent:
        return const Color(0xFFF44336); // Red
    }
  }
}

extension NewsTypeExtension on NewsType {
  String get displayName {
    switch (this) {
      case NewsType.alert:
        return 'Alert';
      case NewsType.newsletter:
        return 'Newsletter';
      case NewsType.announcement:
        return 'Announcement';
      case NewsType.update:
        return 'Update';
    }
  }

  IconData get icon {
    switch (this) {
      case NewsType.alert:
        return Icons.warning;
      case NewsType.newsletter:
        return Icons.article;
      case NewsType.announcement:
        return Icons.campaign;
      case NewsType.update:
        return Icons.info;
    }
  }
}
