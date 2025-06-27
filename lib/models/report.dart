import 'package:cloud_firestore/cloud_firestore.dart';

class ReportImage {
  final String url;
  final String type;
  final DateTime timestamp;

  ReportImage({
    required this.url,
    required this.type,
    required this.timestamp,
  });

  factory ReportImage.fromMap(Map<String, dynamic> map) {
    return ReportImage(
      url: map['url'] as String,
      type: map['type'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

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
  final List<String> imageUrls; // Keep for backward compatibility
  final List<ReportImage> images; // New structured images
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
    this.images = const [],
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
      images: (map['images'] as List<dynamic>?)
          ?.map((item) => ReportImage.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
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
      'images': images.map((image) => image.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper method to get images sorted by type priority
  List<ReportImage> get sortedImages {
    final typeOrder = ['upstream', 'downstream', 'soil_strate', 'coating_overview'];
    final sorted = List<ReportImage>.from(images);
    
    sorted.sort((a, b) {
      final aIndex = typeOrder.indexOf(a.type);
      final bIndex = typeOrder.indexOf(b.type);
      
      // If both types are in the priority list, sort by priority
      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }
      
      // If only one is in the priority list, prioritize it
      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;
      
      // If neither is in the priority list, sort by timestamp
      return a.timestamp.compareTo(b.timestamp);
    });
    
    return sorted;
  }
}
