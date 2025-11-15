import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/personal_folder.dart';
import '../models/personal_location.dart';

class PersonalLocationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // PERSONAL FOLDERS CRUD OPERATIONS

  /// Get all folders for a specific user
  Stream<List<PersonalFolder>> getUserFolders(String userId) {
    return _firestore
        .collection('personal_folders')
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PersonalFolder.fromFirestore(doc))
            .toList());
  }

  /// Get folder by ID (with user permission check)
  Future<PersonalFolder?> getFolderById(String folderId, String userId) async {
    try {
      final doc = await _firestore.collection('personal_folders').doc(folderId).get();
      if (doc.exists) {
        final folder = PersonalFolder.fromFirestore(doc);
        // Only return folder if it belongs to the current user
        return folder.userId == userId ? folder : null;
      }
      return null;
    } catch (e) {
      print('Error getting folder: $e');
      return null;
    }
  }

  /// Create new personal folder
  Future<String?> createFolder(PersonalFolder folder) async {
    try {
      final docRef = await _firestore
          .collection('personal_folders')
          .add(folder.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating folder: $e');
      rethrow;
    }
  }

  /// Update folder (with user permission check)
  Future<void> updateFolder(PersonalFolder folder) async {
    try {
      // Verify the user owns this folder
      final existingFolder = await getFolderById(folder.id!, folder.userId);
      if (existingFolder == null) {
        throw Exception('Folder not found or access denied');
      }

      await _firestore
          .collection('personal_folders')
          .doc(folder.id)
          .update(folder.toFirestore());
    } catch (e) {
      print('Error updating folder: $e');
      rethrow;
    }
  }

  /// Delete folder and all its locations (with user permission check)
  Future<void> deleteFolder(String folderId, String userId) async {
    try {
      // Verify the user owns this folder
      final folder = await getFolderById(folderId, userId);
      if (folder == null) {
        throw Exception('Folder not found or access denied');
      }

      // Delete all locations in this folder
      final locations = await getLocationsByFolder(folderId, userId).first;
      for (final location in locations) {
        await deleteLocation(location.id!, userId);
      }
      
      // Delete the folder
      await _firestore.collection('personal_folders').doc(folderId).delete();
    } catch (e) {
      print('Error deleting folder: $e');
      rethrow;
    }
  }

  // PERSONAL LOCATIONS CRUD OPERATIONS

  /// Get locations by folder for a specific user
  Stream<List<PersonalLocation>> getLocationsByFolder(String folderId, String userId) {
    return _firestore
        .collection('personal_locations')
        .where('folderId', isEqualTo: folderId)
        .where('userId', isEqualTo: userId)  // Ensure user can only see their own locations
        .orderBy('title')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PersonalLocation.fromFirestore(doc))
            .toList());
  }

  /// Get all locations for a user across all folders
  Stream<List<PersonalLocation>> getAllUserLocations(String userId) {
    return _firestore
        .collection('personal_locations')
        .where('userId', isEqualTo: userId)
        .orderBy('title')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PersonalLocation.fromFirestore(doc))
            .toList());
  }

  /// Get location by ID (with user permission check)
  Future<PersonalLocation?> getLocationById(String locationId, String userId) async {
    try {
      final doc = await _firestore.collection('personal_locations').doc(locationId).get();
      if (doc.exists) {
        final location = PersonalLocation.fromFirestore(doc);
        // Only return location if it belongs to the current user
        return location.userId == userId ? location : null;
      }
      return null;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Create new personal location
  Future<String?> createLocation(PersonalLocation location) async {
    try {
      // Verify the user owns the folder
      final folder = await getFolderById(location.folderId, location.userId);
      if (folder == null) {
        throw Exception('Folder not found or access denied');
      }

      final docRef = await _firestore
          .collection('personal_locations')
          .add(location.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating location: $e');
      rethrow;
    }
  }

  /// Update location (with user permission check)
  Future<void> updateLocation(PersonalLocation location) async {
    try {
      // Verify the user owns this location
      final existingLocation = await getLocationById(location.id!, location.userId);
      if (existingLocation == null) {
        throw Exception('Location not found or access denied');
      }

      await _firestore
          .collection('personal_locations')
          .doc(location.id)
          .update(location.toFirestore());
    } catch (e) {
      print('Error updating location: $e');
      rethrow;
    }
  }

  /// Delete location (with user permission check)
  Future<void> deleteLocation(String locationId, String userId) async {
    try {
      // Verify the user owns this location
      final location = await getLocationById(locationId, userId);
      if (location == null) {
        throw Exception('Location not found or access denied');
      }

      await _firestore.collection('personal_locations').doc(locationId).delete();
    } catch (e) {
      print('Error deleting location: $e');
      rethrow;
    }
  }

  // UTILITY METHODS

  /// Search user's personal locations
  Future<List<PersonalLocation>> searchUserLocations(String userId, String query) async {
    try {
      final results = <PersonalLocation>[];
      final snapshot = await _firestore
          .collection('personal_locations')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in snapshot.docs) {
        final location = PersonalLocation.fromFirestore(doc);
        if (location.title.toLowerCase().contains(query.toLowerCase()) ||
            (location.subtitle?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (location.notes?.toLowerCase().contains(query.toLowerCase()) ?? false)) {
          results.add(location);
        }
      }
      
      return results;
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  /// Get counts for user's personal data
  Future<Map<String, int>> getUserLocationCounts(String userId) async {
    try {
      int folderCount = 0;
      int locationCount = 0;

      final foldersSnapshot = await _firestore
          .collection('personal_folders')
          .where('userId', isEqualTo: userId)
          .get();
      folderCount = foldersSnapshot.docs.length;

      final locationsSnapshot = await _firestore
          .collection('personal_locations')
          .where('userId', isEqualTo: userId)
          .get();
      locationCount = locationsSnapshot.docs.length;

      return {
        'folders': folderCount,
        'locations': locationCount,
      };
    } catch (e) {
      print('Error getting user location counts: $e');
      return {'folders': 0, 'locations': 0};
    }
  }

  /// Validate coordinate format
  bool isValidCoordinateFormat(String coordinates) {
    try {
      final parts = coordinates.split(',');
      if (parts.length != 2) return false;
      
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());
      
      // Basic coordinate validation
      return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    } catch (e) {
      return false;
    }
  }

  /// Check if user has permission to access folder
  Future<bool> canUserAccessFolder(String folderId, String userId) async {
    final folder = await getFolderById(folderId, userId);
    return folder != null;
  }

  /// Check if user has permission to access location
  Future<bool> canUserAccessLocation(String locationId, String userId) async {
    final location = await getLocationById(locationId, userId);
    return location != null;
  }
}
