import 'package:cloud_firestore/cloud_firestore.dart';

enum InspectionMethod {
  mt,
  pt,
  rt,
  ut,
  vt,
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

class FieldLogEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String projectName;
  final double miles;
  final double hours;
  final List<MethodHours> methodHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  FieldLogEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.projectName,
    required this.miles,
    required this.hours,
    required this.methodHours,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FieldLogEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['date'] as Timestamp;
    final utcDate = timestamp.toDate().toUtc();
    
    return FieldLogEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: utcDate,
      projectName: data['projectName'] ?? '',
      miles: (data['miles'] ?? 0).toDouble(),
      hours: (data['hours'] ?? 0).toDouble(),
      methodHours: (data['methodHours'] as List<dynamic>?)
              ?.map((e) => MethodHours.fromFirestore(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate().toUtc(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate().toUtc(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'projectName': projectName,
      'miles': miles,
      'hours': hours,
      'methodHours': methodHours.map((mh) => mh.toFirestore()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper method to get local date
  DateTime get localDate => date.toLocal();
} 