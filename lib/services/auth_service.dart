import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/models/employeeModel.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<EmployeeModel?> login(String email, String password) async {
    debugPrint('[AUTH] Login request for: $email');

    final employeeData = dummyEmployees.firstWhere(
      (e) => e['email'] == email && e['password'] == password,
      orElse: () => {},
    );

    if (employeeData.isEmpty) {
      debugPrint('[AUTH] Login failed: invalid credentials');
      throw Exception('Invalid email or password');
    }

    final employee = EmployeeModel.fromJson(employeeData);
    final sessionToken = 'session_token_${employee.id}';

    await _storage.write(key: AppConstants.tokenKey, value: sessionToken);
    await _storage.write(key: AppConstants.userKey, value: jsonEncode(employee.toJson()));
    await _storage.write(key: AppConstants.roleKey, value: employee.role);

    debugPrint('[AUTH] Login successful: ${employee.name} (${employee.role})');
    return employee;
  }

  Future<EmployeeModel?> getCurrentUser() async {
    final userJson = await _storage.read(key: AppConstants.userKey);
    if (userJson == null) return null;
    try {
      return EmployeeModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    debugPrint('[AUTH] Logout: clearing session');
    await _storage.deleteAll();
  }

  Future<void> forgotPassword(String email) async {
    debugPrint('[AUTH] Password reset requested for: $email');
    final exists = dummyEmployees.any((e) => e['email'] == email);
    if (!exists) {
      throw Exception('Email not registered');
    }
  }
}
