import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/certification.dart';

class CertificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'certifications';

  // Get all certifications for a user
  Stream<List<Certification>> getUserCertifications(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('expiryDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Certification.fromFirestore(doc))
              .toList();
        });
  }

  // Add a new certification
  Future<Certification> addCertification(Certification certification) async {
    final docRef = await _firestore.collection(_collection).add(
          certification.toFirestore(),
        );
    
    return certification.copyWith(id: docRef.id);
  }

  // Update an existing certification
  Future<void> updateCertification(Certification certification) async {
    await _firestore
        .collection(_collection)
        .doc(certification.id)
        .update(certification.toFirestore());
  }

  // Delete a certification
  Future<void> deleteCertification(String certificationId) async {
    await _firestore.collection(_collection).doc(certificationId).delete();
  }

  // Get a single certification by ID
  Future<Certification?> getCertification(String certificationId) async {
    final doc = await _firestore.collection(_collection).doc(certificationId).get();
    
    if (doc.exists) {
      return Certification.fromFirestore(doc);
    }
    
    return null;
  }

  // Get certifications that are expiring soon (within 90 days)
  Stream<List<Certification>> getExpiringSoonCertifications(String userId) {
    final now = DateTime.now();
    final ninetyDaysFromNow = now.add(const Duration(days: 90));
    
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('expiryDate', isGreaterThan: Timestamp.fromDate(now))
        .where('expiryDate', isLessThan: Timestamp.fromDate(ninetyDaysFromNow))
        .orderBy('expiryDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Certification.fromFirestore(doc))
              .toList();
        });
  }

  // Get expired certifications
  Stream<List<Certification>> getExpiredCertifications(String userId) {
    final now = DateTime.now();
    
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('expiryDate', isLessThan: Timestamp.fromDate(now))
        .orderBy('expiryDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Certification.fromFirestore(doc))
              .toList();
        });
  }
}
