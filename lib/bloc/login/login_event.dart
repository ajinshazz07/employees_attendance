part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {
  const LoginEvent();
}

final class LoginSubmittedEvent extends LoginEvent {
  final String email;
  final String password;

  const LoginSubmittedEvent({required this.email, required this.password});
}

final class ForgotPasswordSubmittedEvent extends LoginEvent {
  final String email;

  const ForgotPasswordSubmittedEvent({required this.email});
}

final class CheckLoginStatusEvent extends LoginEvent {
  const CheckLoginStatusEvent();
}
