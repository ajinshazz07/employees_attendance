part of 'employee_management_bloc.dart';

@immutable
sealed class EmployeeManagementState {
  const EmployeeManagementState();
}

final class EmployeeManagementInitial extends EmployeeManagementState {
  const EmployeeManagementInitial();
}

final class EmployeeManagementLoading extends EmployeeManagementState {
  const EmployeeManagementLoading();
}

final class EmployeeManagementLoaded extends EmployeeManagementState {
  final List<EmployeeModel> allEmployees;
  final List<EmployeeModel> filteredEmployees;
  final String searchQuery;

  const EmployeeManagementLoaded({
    required this.allEmployees,
    required this.filteredEmployees,
    this.searchQuery = '',
  });
}

final class EmployeeManagementError extends EmployeeManagementState {
  final String message;

  const EmployeeManagementError({required this.message});
}
