import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/news_update.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _newsCollection => _firestore.collection('news_updates');

  // Get current user info
  String get _currentUserId => _auth.currentUser?.uid ?? 'anonymous';
  String get _currentUserName => _auth.currentUser?.displayName ?? 'Unknown User';

  // Stream of published news updates
  Stream<List<NewsUpdate>> getPublishedUpdates({
    NewsCategory? category,
    int? limit,
  }) {
    Query query = _newsCollection
        .where('isPublished', isEqualTo: true)
        .where('isDraft', isEqualTo: false)
        .orderBy('publishDate', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => NewsUpdate.fromFirestore(doc))
          .where((update) => update.isActive) // Filter out expired updates
          .toList();
    });
  }

  // Stream of all updates (for admin)
  Stream<List<NewsUpdate>> getAllUpdates({
    NewsCategory? category,
    bool? isDraft,
    bool? isPublished,
  }) {
    Query query = _newsCollection.orderBy('lastModified', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    if (isDraft != null) {
      query = query.where('isDraft', isEqualTo: isDraft);
    }

    if (isPublished != null) {
      query = query.where('isPublished', isEqualTo: isPublished);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => NewsUpdate.fromFirestore(doc)).toList();
    });
  }

  // Get single update by ID
  Future<NewsUpdate?> getUpdateById(String id) async {
    try {
      final doc = await _newsCollection.doc(id).get();
      if (doc.exists) {
        return NewsUpdate.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting update by ID: $e');
      return null;
    }
  }

  // Create new update
  Future<String?> createUpdate(NewsUpdate update) async {
    try {
      final docRef = await _newsCollection.add(update.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating update: $e');
      return null;
    }
  }

  // Update existing update
  Future<bool> updateUpdate(String id, NewsUpdate update) async {
    try {
      await _newsCollection.doc(id).update(update.toFirestore());
      return true;
    } catch (e) {
      print('Error updating update: $e');
      return false;
    }
  }

  // Delete update
  Future<bool> deleteUpdate(String id) async {
    try {
      await _newsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting update: $e');
      return false;
    }
  }

  // Publish update (change from draft to published)
  Future<bool> publishUpdate(String id, {DateTime? publishDate}) async {
    try {
      final updateData = {
        'isPublished': true,
        'isDraft': false,
        'publishDate': publishDate != null 
            ? Timestamp.fromDate(publishDate) 
            : Timestamp.now(),
        'lastModified': Timestamp.now(),
      };
      
      await _newsCollection.doc(id).update(updateData);
      return true;
    } catch (e) {
      print('Error publishing update: $e');
      return false;
    }
  }

  // Unpublish update (change back to draft)
  Future<bool> unpublishUpdate(String id) async {
    try {
      final updateData = {
        'isPublished': false,
        'isDraft': true,
        'lastModified': Timestamp.now(),
      };
      
      await _newsCollection.doc(id).update(updateData);
      return true;
    } catch (e) {
      print('Error unpublishing update: $e');
      return false;
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String id) async {
    try {
      await _newsCollection.doc(id).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  // Search updates
  Future<List<NewsUpdate>> searchUpdates(String query, {
    NewsCategory? category,
    bool publishedOnly = true,
  }) async {
    try {
      Query firestoreQuery = _newsCollection;

      if (publishedOnly) {
        firestoreQuery = firestoreQuery
            .where('isPublished', isEqualTo: true)
            .where('isDraft', isEqualTo: false);
      }

      if (category != null) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category.name);
      }

      final snapshot = await firestoreQuery.get();
      final updates = snapshot.docs
          .map((doc) => NewsUpdate.fromFirestore(doc))
          .toList();

      // Filter by search query (client-side since Firestore doesn't support full-text search)
      final searchQuery = query.toLowerCase();
      return updates.where((update) {
        return update.title.toLowerCase().contains(searchQuery) ||
               update.description.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      print('Error searching updates: $e');
      return [];
    }
  }

  // Get updates by category
  Future<List<NewsUpdate>> getUpdatesByCategory(NewsCategory category, {
    bool publishedOnly = true,
    int? limit,
  }) async {
    try {
      Query query = _newsCollection.where('category', isEqualTo: category.name);

      if (publishedOnly) {
        query = query
            .where('isPublished', isEqualTo: true)
            .where('isDraft', isEqualTo: false);
      }

      query = query.orderBy('publishDate', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => NewsUpdate.fromFirestore(doc))
          .where((update) => publishedOnly ? update.isActive : true)
          .toList();
    } catch (e) {
      print('Error getting updates by category: $e');
      return [];
    }
  }

  // Get recent updates (for home screen widget)
  Future<List<NewsUpdate>> getRecentUpdates({int limit = 5}) async {
    try {
      final snapshot = await _newsCollection
          .where('isPublished', isEqualTo: true)
          .where('isDraft', isEqualTo: false)
          .orderBy('publishDate', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => NewsUpdate.fromFirestore(doc))
          .where((update) => update.isActive)
          .toList();
    } catch (e) {
      print('Error getting recent updates: $e');
      return [];
    }
  }

  // Get urgent updates (high priority alerts)
  Future<List<NewsUpdate>> getUrgentUpdates() async {
    try {
      final snapshot = await _newsCollection
          .where('isPublished', isEqualTo: true)
          .where('isDraft', isEqualTo: false)
          .where('priority', isEqualTo: NewsPriority.urgent.name)
          .orderBy('publishDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NewsUpdate.fromFirestore(doc))
          .where((update) => update.isActive)
          .toList();
    } catch (e) {
      print('Error getting urgent updates: $e');
      return [];
    }
  }

  // Create quick alert (helper method for common use case)
  Future<String?> createQuickAlert({
    required String title,
    required String description,
    required NewsCategory category,
    NewsPriority priority = NewsPriority.high,
    DateTime? expirationDate,
    bool publishImmediately = true,
  }) async {
    final update = NewsUpdate(
      title: title,
      description: description,
      createdDate: DateTime.now(),
      publishDate: publishImmediately ? DateTime.now() : null,
      expirationDate: expirationDate,
      category: category,
      priority: priority,
      type: NewsType.alert,
      icon: Icons.notification_important,
      iconName: 'notification_important',
      isPublished: publishImmediately,
      isDraft: !publishImmediately,
      authorId: _currentUserId,
      authorName: _currentUserName,
      lastModified: DateTime.now(),
    );

    return await createUpdate(update);
  }

  // Create newsletter (helper method for common use case)
  Future<String?> createNewsletter({
    required String title,
    required String description,
    required NewsCategory category,
    List<String> links = const [],
    List<String> imageUrls = const [],
    DateTime? publishDate,
    bool publishImmediately = false,
  }) async {
    final update = NewsUpdate(
      title: title,
      description: description,
      createdDate: DateTime.now(),
      publishDate: publishImmediately ? DateTime.now() : publishDate,
      category: category,
      priority: NewsPriority.normal,
      type: NewsType.newsletter,
      icon: Icons.article,
      iconName: 'article',
      isPublished: publishImmediately,
      isDraft: !publishImmediately,
      authorId: _currentUserId,
      authorName: _currentUserName,
      links: links,
      imageUrls: imageUrls,
      lastModified: DateTime.now(),
    );

    return await createUpdate(update);
  }

  // Batch operations
  Future<bool> batchDeleteUpdates(List<String> ids) async {
    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        batch.delete(_newsCollection.doc(id));
      }
      await batch.commit();
      return true;
    } catch (e) {
      print('Error batch deleting updates: $e');
      return false;
    }
  }

  Future<bool> batchPublishUpdates(List<String> ids) async {
    try {
      final batch = _firestore.batch();
      final now = Timestamp.now();
      
      for (final id in ids) {
        batch.update(_newsCollection.doc(id), {
          'isPublished': true,
          'isDraft': false,
          'publishDate': now,
          'lastModified': now,
        });
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error batch publishing updates: $e');
      return false;
    }
  }

  // Analytics methods
  Future<Map<String, int>> getCategoryStats() async {
    try {
      final stats = <String, int>{};
      
      for (final category in NewsCategory.values) {
        final snapshot = await _newsCollection
            .where('category', isEqualTo: category.name)
            .where('isPublished', isEqualTo: true)
            .get();
        stats[category.displayName] = snapshot.docs.length;
      }
      
      return stats;
    } catch (e) {
      print('Error getting category stats: $e');
      return {};
    }
  }

  Future<int> getTotalViewCount() async {
    try {
      final snapshot = await _newsCollection.get();
      int totalViews = 0;
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalViews += (data['viewCount'] as int?) ?? 0;
      }
      
      return totalViews;
    } catch (e) {
      print('Error getting total view count: $e');
      return 0;
    }
  }
}
