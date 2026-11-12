part of 'login_bloc.dart';

@immutable
sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  final EmployeeModel employee;

  const LoginSuccess({required this.employee});
}

final class LoginFailure extends LoginState {
  final String errorMessage;

  const LoginFailure({required this.errorMessage});
}

final class ForgotPasswordSentState extends LoginState {
  final String message;

  const ForgotPasswordSentState({required this.message});
}
