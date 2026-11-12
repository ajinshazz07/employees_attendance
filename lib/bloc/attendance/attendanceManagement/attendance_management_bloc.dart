import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/models/attendanceModel.dart';
import 'package:employees_attendance/models/employeeModel.dart';
import 'package:employees_attendance/services/apiService.dart';
import 'package:employees_attendance/services/local_database_service.dart';

part 'attendance_management_event.dart';
part 'attendance_management_state.dart';

class AttendanceManagementBloc
    extends Bloc<AttendanceManagementEvent, AttendanceManagementState> {
  final LocalDatabaseService dbService;
  final ApiService apiService;

  AttendanceManagementBloc({
    required this.dbService,
    required this.apiService,
  }) : super(const AttendanceManagementInitial()) {
    on<LoadAllAttendanceRecordsEvent>(_onLoadAll);
    on<FilterAttendanceRecordsEvent>(_onFilter);
  }

  Future<void> _onLoadAll(LoadAllAttendanceRecordsEvent event,
      Emitter<AttendanceManagementState> emit) async {
    debugPrint('👉 [BLOC: ATTENDANCE MANAGEMENT] LoadAllAttendanceRecordsEvent received');
    emit(const AttendanceManagementLoading());
    try {
      final employees =
          dummyEmployees.map((e) => EmployeeModel.fromJson(e)).toList();

      var records = await dbService.getAllAttendance();
      if (records.isEmpty) {
        debugPrint('📡 [BLOC: ATTENDANCE MANAGEMENT] No records in SQLite. Syncing from API...');
        final remote = await apiService.fetchUserAttendance();
        for (final r in remote) {
          await dbService.insertAttendance(r);
        }
        records = await dbService.getAllAttendance();
      }
      debugPrint('🎯 [BLOC: ATTENDANCE MANAGEMENT] Emitting loaded with ${records.length} records');
      emit(AttendanceManagementLoaded(records: records, employees: employees));
    } catch (e) {
      debugPrint('❌ [BLOC: ATTENDANCE MANAGEMENT] Error: $e');
      emit(AttendanceManagementError(message: e.toString()));
    }
  }

  Future<void> _onFilter(FilterAttendanceRecordsEvent event,
      Emitter<AttendanceManagementState> emit) async {
    debugPrint('👉 [BLOC: ATTENDANCE MANAGEMENT] Filter event: EmpID=${event.employeeId}, Date=${event.date}');
    emit(const AttendanceManagementLoading());
    try {
      final employees =
          dummyEmployees.map((e) => EmployeeModel.fromJson(e)).toList();
      final records = await dbService.getAllAttendance(
        employeeId: event.employeeId,
        date: event.date,
      );
      debugPrint('🎯 [BLOC: ATTENDANCE MANAGEMENT] Filtered to ${records.length} records');
      emit(AttendanceManagementLoaded(records: records, employees: employees));
    } catch (e) {
      debugPrint('❌ [BLOC: ATTENDANCE MANAGEMENT] Filter error: $e');
      emit(AttendanceManagementError(message: e.toString()));
    }
  }
}
