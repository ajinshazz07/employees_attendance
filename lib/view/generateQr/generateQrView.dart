import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:employees_attendance/bloc/generateQR/generate_qr_bloc.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/services/auth_service.dart';
import 'package:employees_attendance/view/attendance/attendanceManagementView.dart';
import 'package:employees_attendance/view/employeeManagementView/employeeManagementView.dart';
import 'package:employees_attendance/view/login/loginPageView.dart';

class GenerateQrView extends StatefulWidget {
  const GenerateQrView({super.key});

  @override
  State<GenerateQrView> createState() => _GenerateQrViewState();
}

class _GenerateQrViewState extends State<GenerateQrView> {
  Timer? _countdownTimer;
  int _secondsLeft = 0;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    context.read<GenerateQrBloc>().add(const GenerateNewQrSessionEvent());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _countdownTimer?.cancel();
    setState(() => _secondsLeft = seconds);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_secondsLeft > 120) return AppColors.success;
    if (_secondsLeft > 45) return AppColors.warning;
    return AppColors.error;
  }

  Future<void> _logout() async {
    debugPrint('👆 [USER TAP] Admin Sign Out tapped in GenerateQrView');
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPageView()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Admin QR Generator',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded, color: AppColors.textSecondary),
            tooltip: 'Employee Directory',
            onPressed: () {
              debugPrint('👆 [USER TAP] "Employee Management" icon tapped in GenerateQrView AppBar');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmployeeManagementView()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: AppColors.textSecondary),
            tooltip: 'Attendance Management',
            onPressed: () {
              debugPrint('👆 [USER TAP] "Attendance Management" icon tapped in GenerateQrView AppBar');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceManagementView()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<GenerateQrBloc, GenerateQrState>(
        listener: (context, state) {
          if (state is GenerateQrSuccess) {
            _startTimer(state.session.secondsRemaining);
          }
        },
        builder: (context, state) {
          if (state is GenerateQrLoading) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          if (state is GenerateQrError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<GenerateQrBloc>()
                        .add(const RefreshQrSessionEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is GenerateQrSuccess) {
            final isExpired = _secondsLeft <= 0;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    children: [
                      // QR Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            // Timer Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: _timerColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_outlined, size: 16, color: _timerColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    isExpired ? 'Session Expired' : 'Expires in $_formattedTime',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _timerColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // QR Image Container
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: isExpired
                                  ? Container(
                                      width: 200,
                                      height: 200,
                                      alignment: Alignment.center,
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.qr_code_2_rounded,
                                              size: 64, color: AppColors.textMuted),
                                          SizedBox(height: 8),
                                          Text(
                                            'Expired',
                                            style: TextStyle(
                                              color: AppColors.error,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : QrImageView(
                                      data: state.qrDataString,
                                      version: QrVersions.auto,
                                      size: 200,
                                      backgroundColor: Colors.transparent,
                                    ),
                            ),
                            const SizedBox(height: 16),

                            // Session Info
                            Text(
                              'ID: ${state.session.sessionId.substring(0, 8)}...',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Regenerate Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            debugPrint('👆 [USER TAP] "Regenerate QR Code" button tapped in GenerateQrView');
                            context
                                .read<GenerateQrBloc>()
                                .add(const RefreshQrSessionEvent());
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text(
                            'Regenerate QR Code',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Display this dynamic code at the entrance for employees to check in.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
