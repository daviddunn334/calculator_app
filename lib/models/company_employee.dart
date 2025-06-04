class CompanyEmployee {
  final String? id;
  final String firstName;
  final String lastName;
  final String position;
  final String department;
  final String email;
  final String phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String status;
  final List<String> certifications;

  CompanyEmployee({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.department,
    required this.email,
    required this.phone,
    this.createdAt,
    this.updatedAt,
    this.status = 'active',
    this.certifications = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'position': position,
      'department': department,
      'email': email,
      'phone': phone,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'status': status,
      'certifications': certifications,
    };
  }

  factory CompanyEmployee.fromMap(Map<String, dynamic> map) {
    return CompanyEmployee(
      id: map['id'] as String?,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      position: map['position'] as String,
      department: map['department'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      status: map['status'] as String? ?? 'active',
      certifications: List<String>.from(map['certifications'] ?? []),
    );
  }

  CompanyEmployee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? position,
    String? department,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    List<String>? certifications,
  }) {
    return CompanyEmployee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      position: position ?? this.position,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      certifications: certifications ?? this.certifications,
    );
  }
} 