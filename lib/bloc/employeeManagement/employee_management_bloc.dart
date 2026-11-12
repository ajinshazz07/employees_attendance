import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/models/employeeModel.dart';

part 'employee_management_event.dart';
part 'employee_management_state.dart';

class EmployeeManagementBloc
    extends Bloc<EmployeeManagementEvent, EmployeeManagementState> {
  List<EmployeeModel> _cachedEmployees = [];

  EmployeeManagementBloc() : super(const EmployeeManagementInitial()) {
    on<LoadEmployeesListEvent>(_onLoadList);
    on<SearchEmployeesEvent>(_onSearch);
  }

  void _onLoadList(
      LoadEmployeesListEvent event, Emitter<EmployeeManagementState> emit) {
    debugPrint('👉 [BLOC: EMPLOYEE MANAGEMENT] LoadEmployeesListEvent received');
    emit(const EmployeeManagementLoading());
    try {
      _cachedEmployees =
          dummyEmployees.map((e) => EmployeeModel.fromJson(e)).toList();
      debugPrint('🎯 [BLOC: EMPLOYEE MANAGEMENT] Loaded ${_cachedEmployees.length} employees');
      emit(EmployeeManagementLoaded(
        allEmployees: _cachedEmployees,
        filteredEmployees: _cachedEmployees,
      ));
    } catch (e) {
      debugPrint('❌ [BLOC: EMPLOYEE MANAGEMENT] Error: $e');
      emit(EmployeeManagementError(message: e.toString()));
    }
  }

  void _onSearch(
      SearchEmployeesEvent event, Emitter<EmployeeManagementState> emit) {
    final q = event.query.toLowerCase().trim();
    debugPrint('👉 [BLOC: EMPLOYEE MANAGEMENT] Search event query: "$q"');
    if (q.isEmpty) {
      emit(EmployeeManagementLoaded(
        allEmployees: _cachedEmployees,
        filteredEmployees: _cachedEmployees,
        searchQuery: '',
      ));
    } else {
      final filtered = _cachedEmployees
          .where((e) =>
              e.name.toLowerCase().contains(q) ||
              e.id.toLowerCase().contains(q) ||
              e.department.toLowerCase().contains(q))
          .toList();
      debugPrint('🎯 [BLOC: EMPLOYEE MANAGEMENT] Found ${filtered.length} matches for "$q"');
      emit(EmployeeManagementLoaded(
        allEmployees: _cachedEmployees,
        filteredEmployees: filtered,
        searchQuery: event.query,
      ));
    }
  }
}
