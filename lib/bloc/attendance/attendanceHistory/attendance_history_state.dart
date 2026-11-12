part of 'attendance_history_bloc.dart';

@immutable
sealed class AttendanceHistoryState {
  const AttendanceHistoryState();
}

final class AttendanceHistoryInitial extends AttendanceHistoryState {
  const AttendanceHistoryInitial();
}

final class AttendanceHistoryLoading extends AttendanceHistoryState {
  const AttendanceHistoryLoading();
}

final class AttendanceHistoryLoaded extends AttendanceHistoryState {
  final List<AttendanceModel> records;

  const AttendanceHistoryLoaded({required this.records});
}

final class AttendanceHistoryError extends AttendanceHistoryState {
  final String message;

  const AttendanceHistoryError({required this.message});
}
