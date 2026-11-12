import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/firebase_options.dart';
import 'package:employees_attendance/services/apiService.dart';
import 'package:employees_attendance/services/auth_service.dart';
import 'package:employees_attendance/services/local_database_service.dart';
import 'package:employees_attendance/services/location_service.dart';
import 'package:employees_attendance/services/qr_service.dart';

import 'package:employees_attendance/bloc/login/login_bloc.dart';
import 'package:employees_attendance/bloc/dashboard/dashboard_bloc.dart';
import 'package:employees_attendance/bloc/scannerPage/scanner_page_bloc.dart';
import 'package:employees_attendance/bloc/attendance/attendanceHistory/attendance_history_bloc.dart';
import 'package:employees_attendance/bloc/attendance/attendanceManagement/attendance_management_bloc.dart';
import 'package:employees_attendance/bloc/generateQR/generate_qr_bloc.dart';
import 'package:employees_attendance/bloc/employeeManagement/employee_management_bloc.dart';
import 'package:employees_attendance/bloc/profile/profile_bloc.dart';

import 'package:employees_attendance/view/splash/SplashScreenView.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Allows execution when Firebase options or offline mode is running
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dbService = LocalDatabaseService();
    final apiService = ApiService();
    final locationService = LocationService();
    final qrService = QrService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (_) => LoginBloc(authService: authService),
        ),
        BlocProvider<DashboardBloc>(
          create: (_) => DashboardBloc(
            authService: authService,
            dbService: dbService,
            apiService: apiService,
          ),
        ),
        BlocProvider<ScannerPageBloc>(
          create: (_) => ScannerPageBloc(
            qrService: qrService,
            dbService: dbService,
            apiService: apiService,
            locationService: locationService,
            authService: authService,
          ),
        ),
        BlocProvider<AttendanceHistoryBloc>(
          create: (_) => AttendanceHistoryBloc(
            dbService: dbService,
            apiService: apiService,
          ),
        ),
        BlocProvider<AttendanceManagementBloc>(
          create: (_) => AttendanceManagementBloc(
            dbService: dbService,
            apiService: apiService,
          ),
        ),
        BlocProvider<GenerateQrBloc>(
          create: (_) => GenerateQrBloc(
            qrService: qrService,
            dbService: dbService,
            authService: authService,
          ),
        ),
        BlocProvider<EmployeeManagementBloc>(
          create: (_) => EmployeeManagementBloc(),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(authService: authService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Employee Attendance',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        home: const SplashscreenView(),
      ),
    );
  }
}
