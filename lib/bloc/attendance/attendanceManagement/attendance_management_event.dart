part of 'attendance_management_bloc.dart';

@immutable
sealed class AttendanceManagementEvent {
  const AttendanceManagementEvent();
}

final class LoadAllAttendanceRecordsEvent extends AttendanceManagementEvent {
  const LoadAllAttendanceRecordsEvent();
}

final class FilterAttendanceRecordsEvent extends AttendanceManagementEvent {
  final int? employeeId;
  final String? date;

  const FilterAttendanceRecordsEvent({this.employeeId, this.date});
}
