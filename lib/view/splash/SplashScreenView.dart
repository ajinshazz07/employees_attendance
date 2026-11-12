import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
    // Duration allows Lottie animation to complete smoothly (~2.5s)
    await Future.delayed(const Duration(milliseconds: 2500));
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
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // Full Screen Lottie Splash Animation
          Positioned.fill(
            child: Lottie.asset(
              'asset/lotties/splash_screen.json',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Lottie.asset(
                  'asset/lotties/spalsh screen.json',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                );
              },
            ),
          ),

          // App Logo Aligned in the Exact Center
          Center(
            child: Image.asset(
              'asset/images/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
