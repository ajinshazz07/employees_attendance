class EmployeeModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String phone;
  final String joinDate;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.phone,
    required this.joinDate,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        role: json['role']?.toString() ?? 'employee',
        department: json['department']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        joinDate: json['joinDate']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'department': department,
        'phone': phone,
        'joinDate': joinDate,
      };
}

