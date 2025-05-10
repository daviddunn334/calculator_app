class CompanyEmployee {
  final int? id;
  final String firstName;
  final String lastName;
  final String? position;
  final String? department;
  final String? email;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CompanyEmployee({
    this.id,
    required this.firstName,
    required this.lastName,
    this.position,
    this.department,
    this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'position': position,
      'department': department,
      'email': email,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory CompanyEmployee.fromMap(Map<String, dynamic> map) {
    return CompanyEmployee(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      position: map['position'],
      department: map['department'],
      email: map['email'],
      phone: map['phone'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
} 