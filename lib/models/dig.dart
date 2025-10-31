import 'package:cloud_firestore/cloud_firestore.dart';

class Dig {
  final String? id;
  final String divisionId;
  final String projectId;
  final String digNumber;
  final String rgwNumber;
  final String coordinates; // Store as "lat,lng" string for easy maps integration
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;

  Dig({
    this.id,
    required this.divisionId,
    required this.projectId,
    required this.digNumber,
    required this.rgwNumber,
    required this.coordinates,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
    required this.createdBy,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Dig.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Dig(
      id: doc.id,
      divisionId: data['divisionId'] ?? '',
      projectId: data['projectId'] ?? '',
      digNumber: data['digNumber'] ?? '',
      rgwNumber: data['rgwNumber'] ?? '',
      coordinates: data['coordinates'] ?? '',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'divisionId': divisionId,
      'projectId': projectId,
      'digNumber': digNumber,
      'rgwNumber': rgwNumber,
      'coordinates': coordinates,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    };
  }

  // Helper methods for coordinates
  double? get latitude {
    try {
      final parts = coordinates.split(',');
      if (parts.length >= 2) {
        return double.parse(parts[0].trim());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  double? get longitude {
    try {
      final parts = coordinates.split(',');
      if (parts.length >= 2) {
        return double.parse(parts[1].trim());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Generate maps URLs for different apps
  String get googleMapsUrl {
    final lat = latitude;
    final lng = longitude;
    if (lat != null && lng != null) {
      return 'https://www.google.com/maps?q=$lat,$lng';
    }
    return '';
  }

  String get appleMapsUrl {
    final lat = latitude;
    final lng = longitude;
    if (lat != null && lng != null) {
      return 'http://maps.apple.com/?q=$lat,$lng';
    }
    return '';
  }

  bool get hasValidCoordinates {
    return latitude != null && longitude != null;
  }

  Dig copyWith({
    String? digNumber,
    String? rgwNumber,
    String? coordinates,
    String? notes,
  }) {
    return Dig(
      id: id,
      divisionId: divisionId,
      projectId: projectId,
      digNumber: digNumber ?? this.digNumber,
      rgwNumber: rgwNumber ?? this.rgwNumber,
      coordinates: coordinates ?? this.coordinates,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdBy: createdBy,
    );
  }
}
