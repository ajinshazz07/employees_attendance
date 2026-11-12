import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:employees_attendance/bloc/dashboard/dashboard_bloc.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/models/attendanceModel.dart';
import 'package:employees_attendance/view/attendance/attendanceHistoryView.dart';
import 'package:employees_attendance/view/profile/profileView.dart';
import 'package:employees_attendance/view/scannerPage/scannerPageView.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboardEvent());
  }

  Future<void> _openScanner({String source = 'General'}) async {
    debugPrint('👆 [USER TAP] Scan Attendance QR initiated (Source: $source)');
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScannerPageView()),
    );
    if (mounted) {
      debugPrint('🔄 [DASHBOARD] Returned from scanner. Refreshing dashboard data...');
      context.read<DashboardBloc>().add(const RefreshDashboardEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
            tooltip: 'Attendance History',
            onPressed: () {
              debugPrint('👆 [USER TAP] Attendance History icon tapped from Dashboard AppBar');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceHistoryView()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
            tooltip: 'Profile',
            onPressed: () {
              debugPrint('👆 [USER TAP] Profile icon tapped from Dashboard AppBar');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileView()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<DashboardBloc>()
                        .add(const LoadDashboardEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                debugPrint('👆 [USER TAP] Pull to refresh triggered on Dashboard');
                context.read<DashboardBloc>().add(const RefreshDashboardEvent());
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  // User Profile Greeting
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          state.employee.name.isNotEmpty
                              ? state.employee.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.employee.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${state.employee.id} • ${state.employee.department}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Today's Status Banner
                  _todayStatusCard(state.todayAttendance),
                  const SizedBox(height: 16),

                  // Scan QR Large CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _openScanner(source: 'Large Action Button'),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                      label: const Text(
                        'Scan Attendance QR',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Attendance Summary Section
                  const Text(
                    'Monthly Overview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard('Present', '${state.totalPresent}', AppColors.success),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard('Late', '${state.totalLate}', AppColors.warning),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard('Absent', '${state.totalAbsent}', AppColors.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Balances Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Leave Balance',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text('${state.leaveBalance} Days',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  )),
                            ],
                          ),
                        ),
                        Container(height: 32, width: 1, color: AppColors.border),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Overtime',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text('${state.overtimeHours} Hours',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Action Links
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            debugPrint('👆 [USER TAP] "View History" button tapped on Dashboard');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AttendanceHistoryView()),
                            );
                          },
                          icon: const Icon(Icons.history_rounded, size: 18),
                          label: const Text('Full History'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            debugPrint('👆 [USER TAP] "My Profile" button tapped on Dashboard');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileView()),
                            );
                          },
                          icon: const Icon(Icons.person_outline_rounded, size: 18),
                          label: const Text('My Profile'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _todayStatusCard(AttendanceModel? attendance) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM d').format(now);
    final hasCheckedIn = attendance != null;
    final hasCheckedOut = attendance?.checkOutTime != null;

    String statusText;
    Color statusColor;

    if (!hasCheckedIn) {
      statusText = 'Not Checked In';
      statusColor = AppColors.error;
    } else if (hasCheckedOut) {
      statusText = 'Shift Completed';
      statusColor = AppColors.success;
    } else {
      statusText = 'Checked In';
      statusColor = AppColors.accent;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _timestampBox(
                  label: 'Check-In',
                  time: attendance?.checkInTime ?? '--:--',
                  isActive: !hasCheckedIn,
                  onTap: !hasCheckedIn
                      ? () => _openScanner(source: 'Check-In Tile')
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _timestampBox(
                  label: 'Check-Out',
                  time: attendance?.checkOutTime ?? '--:--',
                  isActive: hasCheckedIn && !hasCheckedOut,
                  onTap: (hasCheckedIn && !hasCheckedOut)
                      ? () => _openScanner(source: 'Check-Out Tile')
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timestampBox({
    required String label,
    required String time,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.accent.withValues(alpha: 0.3) : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (isActive)
                  const Icon(Icons.touch_app_rounded, size: 14, color: AppColors.accent),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: time == '--:--' ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
