import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String userId;
  final String technicianName;
  final DateTime inspectionDate;
  final String location;
  final String pipeDiameter;
  final String wallThickness;
  final String method;
  final String findings;
  final String correctiveActions;
  final String? additionalNotes;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.userId,
    required this.technicianName,
    required this.inspectionDate,
    required this.location,
    required this.pipeDiameter,
    required this.wallThickness,
    required this.method,
    required this.findings,
    required this.correctiveActions,
    this.additionalNotes,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] as String,
      userId: map['userId'] as String,
      technicianName: map['technicianName'] as String,
      inspectionDate: (map['inspectionDate'] as Timestamp).toDate(),
      location: map['location'] as String,
      pipeDiameter: map['pipeDiameter'] as String,
      wallThickness: map['wallThickness'] as String,
      method: map['method'] as String,
      findings: map['findings'] as String,
      correctiveActions: map['correctiveActions'] as String,
      additionalNotes: map['additionalNotes'] as String?,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'technicianName': technicianName,
      'inspectionDate': Timestamp.fromDate(inspectionDate),
      'location': location,
      'pipeDiameter': pipeDiameter,
      'wallThickness': wallThickness,
      'method': method,
      'findings': findings,
      'correctiveActions': correctiveActions,
      'additionalNotes': additionalNotes,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
