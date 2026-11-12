import 'package:flutter/material.dart';

const String dummyUserAttendanceBaseUrl = 'https://databasesample.com';
const String dummyUserAttendanceEndpoint =
    '/mock/employee-attendance-and-leave-management/employee_attendance?_page=1&_limit=5';

class AppConstants {
  static const String baseUrl = dummyUserAttendanceBaseUrl;
  static const String attendanceEndpoint = dummyUserAttendanceEndpoint;

  // QR expiry in seconds (5 minutes)
  static const int qrExpirySeconds = 300;

  // Office Location for Geofencing
  static const double officeLatitude = 37.7749;
  static const double officeLongitude = -122.4194;
  static const double allowedRadiusMeters = 500;

  // Secure Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String roleKey = 'user_role';

  // User Roles
  static const String roleEmployee = 'employee';
  static const String roleAdmin = 'admin';

  // SQLite DB
  static const String dbName = 'attendance_records.db';
  static const int dbVersion = 1;
}

class AppColors {
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color accent = Color(0xFF2563EB); // Royal Blue
  static const Color success = Color(0xFF16A34A); // Emerald 600
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate 100
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Backward compatibility
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color secondary = Color(0xFF2563EB);
  static const Color gradient1 = Color(0xFF0F172A);
  static const Color gradient2 = Color(0xFF1E293B);
}

final List<Map<String, dynamic>> dummyEmployees = [
  {
    'id': 'EMP001',
    'name': 'Alice Johnson',
    'email': 'alice@company.com',
    'password': 'password123',
    'role': 'employee',
    'department': 'Engineering',
    'phone': '+1-555-0101',
    'joinDate': '2022-01-15',
  },
  {
    'id': 'EMP002',
    'name': 'Bob Smith',
    'email': 'bob@company.com',
    'password': 'password123',
    'role': 'employee',
    'department': 'Design',
    'phone': '+1-555-0102',
    'joinDate': '2021-06-10',
  },
  {
    'id': 'EMP003',
    'name': 'Carol White',
    'email': 'carol@company.com',
    'password': 'password123',
    'role': 'employee',
    'department': 'Marketing',
    'phone': '+1-555-0103',
    'joinDate': '2023-03-20',
  },
  {
    'id': 'ADM001',
    'name': 'David Admin',
    'email': 'admin@company.com',
    'password': 'admin123',
    'role': 'admin',
    'department': 'Administration',
    'phone': '+1-555-0100',
    'joinDate': '2020-01-01',
  },
];
