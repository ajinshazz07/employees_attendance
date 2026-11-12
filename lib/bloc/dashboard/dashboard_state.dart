part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  final EmployeeModel employee;
  final AttendanceModel? todayAttendance;
  final int totalPresent;
  final int totalAbsent;
  final int totalLate;
  final double leaveBalance;
  final double overtimeHours;

  const DashboardLoaded({
    required this.employee,
    this.todayAttendance,
    required this.totalPresent,
    required this.totalAbsent,
    required this.totalLate,
    required this.leaveBalance,
    required this.overtimeHours,
  });
}

final class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});
}
