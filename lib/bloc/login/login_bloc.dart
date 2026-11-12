import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:employees_attendance/models/employeeModel.dart';
import 'package:employees_attendance/services/auth_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService authService;

  LoginBloc({required this.authService}) : super(const LoginInitial()) {
    on<LoginSubmittedEvent>(_onLogin);
    on<ForgotPasswordSubmittedEvent>(_onForgotPassword);
    on<CheckLoginStatusEvent>(_onCheckStatus);
  }

  Future<void> _onLogin(LoginSubmittedEvent event, Emitter<LoginState> emit) async {
    debugPrint('👉 [BLOC] LoginSubmittedEvent received: email=${event.email}');
    emit(const LoginLoading());
    try {
      final employee = await authService.login(event.email, event.password);
      if (employee != null) {
        debugPrint('🎯 [BLOC] LoginSuccess emitted for ${employee.name} (${employee.role})');
        emit(LoginSuccess(employee: employee));
      } else {
        debugPrint('⚠️ [BLOC] LoginFailure emitted: Invalid login credentials');
        emit(const LoginFailure(errorMessage: 'Invalid login credentials'));
      }
    } catch (e) {
      debugPrint('⚠️ [BLOC] LoginFailure caught exception: $e');
      emit(LoginFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onForgotPassword(
      ForgotPasswordSubmittedEvent event, Emitter<LoginState> emit) async {
    debugPrint('👉 [BLOC] ForgotPasswordSubmittedEvent received: email=${event.email}');
    try {
      await authService.forgotPassword(event.email);
      debugPrint('🎯 [BLOC] ForgotPasswordSentState emitted for: ${event.email}');
      emit(const ForgotPasswordSentState(
          message: 'Password reset link sent to your registered email address'));
    } catch (e) {
      debugPrint('⚠️ [BLOC] ForgotPassword failed: $e');
      emit(LoginFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCheckStatus(
      CheckLoginStatusEvent event, Emitter<LoginState> emit) async {
    debugPrint('👉 [BLOC] CheckLoginStatusEvent received');
    final loggedIn = await authService.isLoggedIn();
    if (loggedIn) {
      final user = await authService.getCurrentUser();
      if (user != null) {
        debugPrint('🎯 [BLOC] Session active: Auto-logging in user ${user.name}');
        emit(LoginSuccess(employee: user));
        return;
      }
    }
    emit(const LoginInitial());
  }
}
