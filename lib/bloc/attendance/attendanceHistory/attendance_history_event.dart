part of 'attendance_history_bloc.dart';

@immutable
sealed class AttendanceHistoryEvent {
  const AttendanceHistoryEvent();
}

final class LoadAttendanceHistoryEvent extends AttendanceHistoryEvent {
  final int employeeId;
  final String? fromDate;
  final String? toDate;

  const LoadAttendanceHistoryEvent({
    required this.employeeId,
    this.fromDate,
    this.toDate,
  });
}

final class FilterAttendanceHistoryEvent extends AttendanceHistoryEvent {
  final String? fromDate;
  final String? toDate;

  const FilterAttendanceHistoryEvent({this.fromDate, this.toDate});
}
