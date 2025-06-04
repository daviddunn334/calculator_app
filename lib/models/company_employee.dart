class CompanyEmployee {
  final String? id;
  final String firstName;
  final String lastName;
  final String? position;
  final String? department;
  final String? email;
  final String? phone;
  final List<String> certifications;
  final String status;

  CompanyEmployee({
    this.id,
    required this.firstName,
    required this.lastName,
    this.position,
    this.department,
    this.email,
    this.phone,
    this.certifications = const [],
    this.status = 'active',
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
      'certifications': certifications,
      'status': status,
    };
  }

  factory CompanyEmployee.fromMap(Map<String, dynamic> map) {
    return CompanyEmployee(
      id: map['id'],
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      position: map['position'],
      department: map['department'],
      email: map['email'],
      phone: map['phone'],
      certifications: List<String>.from(map['certifications'] ?? []),
      status: map['status'] ?? 'active',
    );
  }
} 