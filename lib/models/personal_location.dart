import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalLocation {
  final String? id;
  final String userId;
  final String folderId;
  final String title;
  final String? subtitle;
  final String coordinates; // Store as "lat,lng" string for easy maps integration
  final String? notes;
  final String colorHex;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PersonalLocation({
    this.id,
    required this.userId,
    required this.folderId,
    required this.title,
    this.subtitle,
    required this.coordinates,
    this.notes,
    this.colorHex = 'FFB703', // Default to yellow
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PersonalLocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PersonalLocation(
      id: doc.id,
      userId: data['userId'] ?? '',
      folderId: data['folderId'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      coordinates: data['coordinates'] ?? '',
      notes: data['notes'],
      colorHex: data['colorHex'] ?? 'FFB703',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'folderId': folderId,
      'title': title,
      'subtitle': subtitle,
      'coordinates': coordinates,
      'notes': notes,
      'colorHex': colorHex,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
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

  PersonalLocation copyWith({
    String? title,
    String? subtitle,
    String? coordinates,
    String? notes,
    String? colorHex,
  }) {
    return PersonalLocation(
      id: id,
      userId: userId,
      folderId: folderId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      coordinates: coordinates ?? this.coordinates,
      notes: notes ?? this.notes,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
