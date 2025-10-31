import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/division.dart';
import '../models/project.dart';
import '../models/dig.dart';

class JobLocationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // DIVISIONS CRUD OPERATIONS

  /// Get all divisions
  Stream<List<Division>> getAllDivisions() {
    return _firestore
        .collection('divisions')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Division.fromFirestore(doc))
            .toList());
  }

  /// Get division by ID
  Future<Division?> getDivisionById(String divisionId) async {
    try {
      final doc = await _firestore.collection('divisions').doc(divisionId).get();
      return doc.exists ? Division.fromFirestore(doc) : null;
    } catch (e) {
      print('Error getting division: $e');
      return null;
    }
  }

  /// Create new division
  Future<String?> createDivision(Division division) async {
    try {
      final docRef = await _firestore
          .collection('divisions')
          .add(division.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating division: $e');
      rethrow;
    }
  }

  /// Update division
  Future<void> updateDivision(Division division) async {
    try {
      await _firestore
          .collection('divisions')
          .doc(division.id)
          .update(division.toFirestore());
    } catch (e) {
      print('Error updating division: $e');
      rethrow;
    }
  }

  /// Delete division and all its projects and digs
  Future<void> deleteDivision(String divisionId) async {
    try {
      // Delete all projects and their digs first
      final projects = await getProjectsByDivision(divisionId).first;
      for (final project in projects) {
        await deleteProject(project.id!);
      }
      
      // Delete the division
      await _firestore.collection('divisions').doc(divisionId).delete();
    } catch (e) {
      print('Error deleting division: $e');
      rethrow;
    }
  }

  // PROJECTS CRUD OPERATIONS

  /// Get projects by division
  Stream<List<Project>> getProjectsByDivision(String divisionId) {
    return _firestore
        .collection('divisions')
        .doc(divisionId)
        .collection('projects')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromFirestore(doc))
            .toList());
  }

  /// Get project by ID
  Future<Project?> getProjectById(String divisionId, String projectId) async {
    try {
      final doc = await _firestore
          .collection('divisions')
          .doc(divisionId)
          .collection('projects')
          .doc(projectId)
          .get();
      return doc.exists ? Project.fromFirestore(doc) : null;
    } catch (e) {
      print('Error getting project: $e');
      return null;
    }
  }

  /// Create new project
  Future<String?> createProject(Project project) async {
    try {
      final docRef = await _firestore
          .collection('divisions')
          .doc(project.divisionId)
          .collection('projects')
          .add(project.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating project: $e');
      rethrow;
    }
  }

  /// Update project
  Future<void> updateProject(Project project) async {
    try {
      await _firestore
          .collection('divisions')
          .doc(project.divisionId)
          .collection('projects')
          .doc(project.id)
          .update(project.toFirestore());
    } catch (e) {
      print('Error updating project: $e');
      rethrow;
    }
  }

  /// Delete project and all its digs
  Future<void> deleteProject(String projectId) async {
    try {
      // First, get the project to know which division it belongs to
      final divisionsSnapshot = await _firestore.collection('divisions').get();
      
      for (final divisionDoc in divisionsSnapshot.docs) {
        final projectDoc = await divisionDoc.reference
            .collection('projects')
            .doc(projectId)
            .get();
            
        if (projectDoc.exists) {
          // Delete all digs first
          final digs = await getDigsByProject(divisionDoc.id, projectId).first;
          for (final dig in digs) {
            await deleteDig(dig.divisionId, dig.projectId, dig.id!);
          }
          
          // Delete the project
          await projectDoc.reference.delete();
          break;
        }
      }
    } catch (e) {
      print('Error deleting project: $e');
      rethrow;
    }
  }

  // DIGS CRUD OPERATIONS

  /// Get digs by project
  Stream<List<Dig>> getDigsByProject(String divisionId, String projectId) {
    return _firestore
        .collection('divisions')
        .doc(divisionId)
        .collection('projects')
        .doc(projectId)
        .collection('digs')
        .orderBy('digNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Dig.fromFirestore(doc))
            .toList());
  }

  /// Get dig by ID
  Future<Dig?> getDigById(String divisionId, String projectId, String digId) async {
    try {
      final doc = await _firestore
          .collection('divisions')
          .doc(divisionId)
          .collection('projects')
          .doc(projectId)
          .collection('digs')
          .doc(digId)
          .get();
      return doc.exists ? Dig.fromFirestore(doc) : null;
    } catch (e) {
      print('Error getting dig: $e');
      return null;
    }
  }

  /// Create new dig
  Future<String?> createDig(Dig dig) async {
    try {
      final docRef = await _firestore
          .collection('divisions')
          .doc(dig.divisionId)
          .collection('projects')
          .doc(dig.projectId)
          .collection('digs')
          .add(dig.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating dig: $e');
      rethrow;
    }
  }

  /// Update dig
  Future<void> updateDig(Dig dig) async {
    try {
      await _firestore
          .collection('divisions')
          .doc(dig.divisionId)
          .collection('projects')
          .doc(dig.projectId)
          .collection('digs')
          .doc(dig.id)
          .update(dig.toFirestore());
    } catch (e) {
      print('Error updating dig: $e');
      rethrow;
    }
  }

  /// Delete dig
  Future<void> deleteDig(String divisionId, String projectId, String digId) async {
    try {
      await _firestore
          .collection('divisions')
          .doc(divisionId)
          .collection('projects')
          .doc(projectId)
          .collection('digs')
          .doc(digId)
          .delete();
    } catch (e) {
      print('Error deleting dig: $e');
      rethrow;
    }
  }

  // UTILITY METHODS

  /// Search digs across all divisions and projects
  Future<List<Dig>> searchDigs(String query) async {
    try {
      final results = <Dig>[];
      final divisionsSnapshot = await _firestore.collection('divisions').get();
      
      for (final divisionDoc in divisionsSnapshot.docs) {
        final projectsSnapshot = await divisionDoc.reference
            .collection('projects')
            .get();
            
        for (final projectDoc in projectsSnapshot.docs) {
          final digsSnapshot = await projectDoc.reference
              .collection('digs')
              .get();
              
          for (final digDoc in digsSnapshot.docs) {
            final dig = Dig.fromFirestore(digDoc);
            if (dig.digNumber.toLowerCase().contains(query.toLowerCase()) ||
                dig.rgwNumber.toLowerCase().contains(query.toLowerCase())) {
              results.add(dig);
            }
          }
        }
      }
      
      return results;
    } catch (e) {
      print('Error searching digs: $e');
      return [];
    }
  }

  /// Get total counts for stats
  Future<Map<String, int>> getLocationCounts() async {
    try {
      int divisionCount = 0;
      int projectCount = 0;
      int digCount = 0;

      final divisionsSnapshot = await _firestore.collection('divisions').get();
      divisionCount = divisionsSnapshot.docs.length;

      for (final divisionDoc in divisionsSnapshot.docs) {
        final projectsSnapshot = await divisionDoc.reference
            .collection('projects')
            .get();
        projectCount += projectsSnapshot.docs.length;

        for (final projectDoc in projectsSnapshot.docs) {
          final digsSnapshot = await projectDoc.reference
              .collection('digs')
              .get();
          digCount += digsSnapshot.docs.length;
        }
      }

      return {
        'divisions': divisionCount,
        'projects': projectCount,
        'digs': digCount,
      };
    } catch (e) {
      print('Error getting location counts: $e');
      return {'divisions': 0, 'projects': 0, 'digs': 0};
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
}
