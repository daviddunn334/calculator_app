class CompanyEmployee {
  final String? id;
  final String firstName;
  final String lastName;
  final String title;      // Display title (can be custom)
  final String group;      // The selected group category
  final String? division; // Optional division
  final String email;
  final String phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CompanyEmployee({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.group,
    this.division,
    required this.email,
    required this.phone,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'title': title,
      'group': group,
      if (division != null) 'division': division,
      'email': email,
      'phone': phone,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory CompanyEmployee.fromMap(Map<String, dynamic> map) {
    return CompanyEmployee(
      id: map['id'] as String?,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      title: map['title'] as String,
      group: map['group'] as String,
      division: map['division'] as String?,
      email: map['email'] as String,
      phone: map['phone'] as String,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  CompanyEmployee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? title,
    String? group,
    String? division,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyEmployee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      title: title ?? this.title,
      group: group ?? this.group,
      division: division ?? this.division,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
