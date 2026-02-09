import 'package:cloud_firestore/cloud_firestore.dart';

enum InspectionMethod {
  mt,
  pt,
  et,
  ut,
  vt,
  lm,
  paut,
}

class MethodHours {
  final double hours;
  final InspectionMethod method;

  MethodHours({
    required this.hours,
    required this.method,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'hours': hours,
      'method': method.name,
    };
  }

  factory MethodHours.fromFirestore(Map<String, dynamic> data) {
    return MethodHours(
      hours: (data['hours'] ?? 0).toDouble(),
      method: InspectionMethod.values.firstWhere(
        (e) => e.name == data['method'],
        orElse: () => InspectionMethod.mt,
      ),
    );
  }
}

class MethodHoursEntry {
  final String id;
  final String userId;
  final DateTime date; // Stored as local date (start of day)
  final String location;
  final String supervisingTechnician;
  final List<MethodHours> methodHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  MethodHoursEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.location,
    required this.supervisingTechnician,
    required this.methodHours,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MethodHoursEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['date'] as Timestamp;
    
    return MethodHoursEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: timestamp.toDate(),
      location: data['location'] ?? '',
      supervisingTechnician: data['supervisingTechnician'] ?? '',
      methodHours: (data['methodHours'] as List<dynamic>?)
              ?.map((e) => MethodHours.fromFirestore(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'location': location,
      'supervisingTechnician': supervisingTechnician,
      'methodHours': methodHours.map((mh) => mh.toFirestore()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper to get normalized date (start of day) for comparison
  DateTime get normalizedDate => DateTime(date.year, date.month, date.day);
}
