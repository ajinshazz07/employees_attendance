import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/services/auth_service.dart';
import 'package:employees_attendance/view/login/loginPageView.dart';
import 'package:employees_attendance/view/dashboard/dashboardView.dart';
import 'package:employees_attendance/view/generateQr/generateQrView.dart';

class SplashscreenView extends StatefulWidget {
  const SplashscreenView({super.key});

  @override
  State<SplashscreenView> createState() => _SplashscreenViewState();
}

class _SplashscreenViewState extends State<SplashscreenView> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    debugPrint('⏳ [SPLASH] Checking user session...');
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        if (user != null && mounted) {
          debugPrint('🎯 [SPLASH] Session restored for ${user.name} (${user.role})');
          if (user.role == AppConstants.roleAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GenerateQrView()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardView()),
            );
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [SPLASH] Session check error: $e');
    }

    if (mounted) {
      debugPrint('ℹ️ [SPLASH] No active session. Directing to LoginPage.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPageView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Attendance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Smart QR Check-In System',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
