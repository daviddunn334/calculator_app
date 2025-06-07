import 'package:cloud_firestore/cloud_firestore.dart';

enum CertificationType {
  asntLevelI,
  asntLevelII,
  asntLevelIII,
  sntTc1a,
  nas410,
  api570,
  api510,
  api653,
  awsCwi,
  cswip,
  cgsbMtLevelI,
  cgsbMtLevelII,
  cgsbUtLevelI,
  cgsbUtLevelII,
  cgsbPautLevelI,
  cgsbPautLevelII,
}

enum CertificationStatus {
  active,
  expiringSoon,
  expired,
}

class Certification {
  final String id;
  final String userId;
  final CertificationType type;
  final String level;
  final String certNumber;
  final DateTime expiryDate;
  final DateTime issuedDate;
  final String? notes;

  Certification({
    required this.id,
    required this.userId,
    required this.type,
    required this.level,
    required this.certNumber,
    required this.expiryDate,
    required this.issuedDate,
    this.notes,
  });

  factory Certification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Certification(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: CertificationType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => CertificationType.asntLevelII,
      ),
      level: data['level'] ?? '',
      certNumber: data['certNumber'] ?? '',
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      issuedDate: (data['issuedDate'] as Timestamp).toDate(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString(),
      'level': level,
      'certNumber': certNumber,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'issuedDate': Timestamp.fromDate(issuedDate),
      'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CertificationStatus getStatus() {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    
    if (expiryDate.isBefore(now)) {
      return CertificationStatus.expired;
    } else if (difference <= 90) {
      return CertificationStatus.expiringSoon;
    } else {
      return CertificationStatus.active;
    }
  }

  String getTypeDisplayName() {
    switch (type) {
      case CertificationType.asntLevelI:
        return 'ASNT Level I';
      case CertificationType.asntLevelII:
        return 'ASNT Level II';
      case CertificationType.asntLevelIII:
        return 'ASNT Level III';
      case CertificationType.sntTc1a:
        return 'SNT-TC-1A';
      case CertificationType.nas410:
        return 'NAS-410';
      case CertificationType.api570:
        return 'API 570';
      case CertificationType.api510:
        return 'API 510';
      case CertificationType.api653:
        return 'API 653';
      case CertificationType.awsCwi:
        return 'AWS CWI (Certified Welding Inspector)';
      case CertificationType.cswip:
        return 'CSWIP';
      case CertificationType.cgsbMtLevelI:
        return 'CGSB MT Level I';
      case CertificationType.cgsbMtLevelII:
        return 'CGSB MT Level II';
      case CertificationType.cgsbUtLevelI:
        return 'CGSB UT Level I';
      case CertificationType.cgsbUtLevelII:
        return 'CGSB UT Level II';
      case CertificationType.cgsbPautLevelI:
        return 'CGSB PAUT Level I';
      case CertificationType.cgsbPautLevelII:
        return 'CGSB PAUT Level II';
    }
  }

  Certification copyWith({
    String? id,
    String? userId,
    CertificationType? type,
    String? level,
    String? certNumber,
    DateTime? expiryDate,
    DateTime? issuedDate,
    String? notes,
  }) {
    return Certification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      level: level ?? this.level,
      certNumber: certNumber ?? this.certNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      issuedDate: issuedDate ?? this.issuedDate,
      notes: notes ?? this.notes,
    );
  }
}
