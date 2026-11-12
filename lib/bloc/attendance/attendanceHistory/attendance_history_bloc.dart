import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:employees_attendance/models/attendanceModel.dart';
import 'package:employees_attendance/services/apiService.dart';
import 'package:employees_attendance/services/local_database_service.dart';

part 'attendance_history_event.dart';
part 'attendance_history_state.dart';

class AttendanceHistoryBloc
    extends Bloc<AttendanceHistoryEvent, AttendanceHistoryState> {
  final LocalDatabaseService dbService;
  final ApiService apiService;
  int? _currentEmpId;

  AttendanceHistoryBloc({
    required this.dbService,
    required this.apiService,
  }) : super(const AttendanceHistoryInitial()) {
    on<LoadAttendanceHistoryEvent>(_onLoadHistory);
    on<FilterAttendanceHistoryEvent>(_onFilterHistory);
  }

  Future<void> _onLoadHistory(LoadAttendanceHistoryEvent event,
      Emitter<AttendanceHistoryState> emit) async {
    _currentEmpId = event.employeeId;
    debugPrint('👉 [BLOC: ATTENDANCE HISTORY] Load event for EmpID=${event.employeeId}, from=${event.fromDate}, to=${event.toDate}');
    emit(const AttendanceHistoryLoading());
    try {
      final localRecords = await dbService.getEmployeeAttendanceHistory(
        event.employeeId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      if (localRecords.isEmpty) {
        debugPrint('📡 [BLOC: ATTENDANCE HISTORY] Local history empty. Syncing from remote API...');
        final remote = await apiService.fetchUserAttendance();
        for (final r in remote) {
          if (r.employeeId == event.employeeId) {
            await dbService.insertAttendance(r);
          }
        }
        final reloaded = await dbService.getEmployeeAttendanceHistory(
          event.employeeId,
          fromDate: event.fromDate,
          toDate: event.toDate,
        );
        debugPrint('🎯 [BLOC: ATTENDANCE HISTORY] Loaded ${reloaded.length} records after API sync.');
        emit(AttendanceHistoryLoaded(records: reloaded));
      } else {
        debugPrint('🎯 [BLOC: ATTENDANCE HISTORY] Loaded ${localRecords.length} records from local DB.');
        emit(AttendanceHistoryLoaded(records: localRecords));
      }
    } catch (e) {
      debugPrint('❌ [BLOC: ATTENDANCE HISTORY] Error: $e');
      emit(AttendanceHistoryError(message: e.toString()));
    }
  }

  Future<void> _onFilterHistory(FilterAttendanceHistoryEvent event,
      Emitter<AttendanceHistoryState> emit) async {
    if (_currentEmpId == null) return;
    debugPrint('👉 [BLOC: ATTENDANCE HISTORY] Filter event: from=${event.fromDate}, to=${event.toDate}');
    emit(const AttendanceHistoryLoading());
    try {
      final filtered = await dbService.getEmployeeAttendanceHistory(
        _currentEmpId!,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );
      debugPrint('🎯 [BLOC: ATTENDANCE HISTORY] Filtered records count: ${filtered.length}');
      emit(AttendanceHistoryLoaded(records: filtered));
    } catch (e) {
      debugPrint('❌ [BLOC: ATTENDANCE HISTORY] Filter Error: $e');
      emit(AttendanceHistoryError(message: e.toString()));
    }
  }
}
