part of 'employee_management_bloc.dart';

@immutable
sealed class EmployeeManagementEvent {
  const EmployeeManagementEvent();
}

final class LoadEmployeesListEvent extends EmployeeManagementEvent {
  const LoadEmployeesListEvent();
}

final class SearchEmployeesEvent extends EmployeeManagementEvent {
  final String query;

  const SearchEmployeesEvent({required this.query});
}
