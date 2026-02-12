import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/defect_type.dart';

class DefectTypeService {
  final CollectionReference _defectTypesCollection =
      FirebaseFirestore.instance.collection('defect_types');

  // Get all active defect types, sorted by sortOrder
  Stream<List<DefectType>> getActiveDefectTypes() {
    return _defectTypesCollection
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DefectType.fromFirestore(doc)).toList());
  }

  // Get all defect types (for admin management)
  Stream<List<DefectType>> getAllDefectTypes() {
    return _defectTypesCollection
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DefectType.fromFirestore(doc)).toList());
  }

  // Initialize default defect types (call this once on first run or from admin)
  Future<void> initializeDefaultDefectTypes() async {
    try {
      // Check if types already exist
      final snapshot = await _defectTypesCollection.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Defect types already initialized');
        return;
      }

      // Default defect types in the order specified
      final defaultTypes = [
        'Corrosion / Loss of Metal',
        'Dent',
        'Crack',
        'Lamination',
        'Lack of Fusion',
        'Gouge',
        'Arc Burn',
        'Hardspot',
        'Wrinkle',
        'Bend',
      ];

      final now = DateTime.now().toUtc();
      final batch = FirebaseFirestore.instance.batch();

      for (var i = 0; i < defaultTypes.length; i++) {
        final docRef = _defectTypesCollection.doc();
        final defectType = DefectType(
          id: docRef.id,
          name: defaultTypes[i],
          isActive: true,
          sortOrder: i,
          createdAt: now,
          updatedAt: now,
        );
        batch.set(docRef, defectType.toFirestore());
      }

      await batch.commit();
      print('Successfully initialized ${defaultTypes.length} defect types');
    } catch (e) {
      print('Error initializing defect types: $e');
      rethrow;
    }
  }

  // Add a new defect type (admin only)
  Future<DefectType> addDefectType(String name) async {
    try {
      // Get the highest sortOrder
      final querySnapshot = await _defectTypesCollection
          .orderBy('sortOrder', descending: true)
          .limit(1)
          .get();
      
      final nextSortOrder = querySnapshot.docs.isEmpty
          ? 0
          : (querySnapshot.docs.first.data() as Map<String, dynamic>)['sortOrder'] + 1;

      final docRef = _defectTypesCollection.doc();
      final now = DateTime.now().toUtc();
      
      final defectType = DefectType(
        id: docRef.id,
        name: name,
        isActive: true,
        sortOrder: nextSortOrder,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(defectType.toFirestore());
      return defectType;
    } catch (e) {
      print('Error adding defect type: $e');
      rethrow;
    }
  }

  // Update defect type (admin only)
  Future<void> updateDefectType(DefectType defectType) async {
    try {
      final updatedType = DefectType(
        id: defectType.id,
        name: defectType.name,
        isActive: defectType.isActive,
        sortOrder: defectType.sortOrder,
        createdAt: defectType.createdAt,
        updatedAt: DateTime.now().toUtc(),
      );

      await _defectTypesCollection.doc(defectType.id).update(updatedType.toFirestore());
    } catch (e) {
      print('Error updating defect type: $e');
      rethrow;
    }
  }

  // Delete defect type (admin only) - soft delete by setting isActive to false
  Future<void> deleteDefectType(String id) async {
    try {
      await _defectTypesCollection.doc(id).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now().toUtc()),
      });
    } catch (e) {
      print('Error deleting defect type: $e');
      rethrow;
    }
  }
}
