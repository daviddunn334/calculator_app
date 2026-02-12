import 'package:cloud_firestore/cloud_firestore.dart';

class DefectEntry {
  final String id;
  final String userId;
  final String defectType;
  final double length; // inches
  final double width; // inches
  final double depth; // inches (or Max HB for Hardspot)
  final String? notes;
  final String clientName; // Client company for AI analysis
  final DateTime createdAt;
  final DateTime updatedAt;

  DefectEntry({
    required this.id,
    required this.userId,
    required this.defectType,
    required this.length,
    required this.width,
    required this.depth,
    this.notes,
    required this.clientName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DefectEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return DefectEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      defectType: data['defectType'] ?? '',
      length: (data['length'] ?? 0).toDouble(),
      width: (data['width'] ?? 0).toDouble(),
      depth: (data['depth'] ?? 0).toDouble(),
      notes: data['notes'],
      clientName: data['clientName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate().toUtc(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate().toUtc(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'defectType': defectType,
      'length': length,
      'width': width,
      'depth': depth,
      'notes': notes,
      'clientName': clientName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper method to get local date
  DateTime get localCreatedAt => createdAt.toLocal();
  DateTime get localUpdatedAt => updatedAt.toLocal();

  // Helper to check if this is a hardspot defect
  bool get isHardspot => defectType.toLowerCase().contains('hardspot');

  // Helper to get the appropriate label for the depth field
  String get depthLabel => isHardspot ? 'Max HB' : 'Depth (in)';
}
