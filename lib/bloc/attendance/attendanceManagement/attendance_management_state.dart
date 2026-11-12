part of 'attendance_management_bloc.dart';

@immutable
sealed class AttendanceManagementState {
  const AttendanceManagementState();
}

final class AttendanceManagementInitial extends AttendanceManagementState {
  const AttendanceManagementInitial();
}

final class AttendanceManagementLoading extends AttendanceManagementState {
  const AttendanceManagementLoading();
}

final class AttendanceManagementLoaded extends AttendanceManagementState {
  final List<AttendanceModel> records;
  final List<EmployeeModel> employees;

  const AttendanceManagementLoaded({
    required this.records,
    required this.employees,
  });
}

final class AttendanceManagementError extends AttendanceManagementState {
  final String message;

  const AttendanceManagementError({required this.message});
}
