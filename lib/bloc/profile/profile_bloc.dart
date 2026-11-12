import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:employees_attendance/models/employeeModel.dart';
import 'package:employees_attendance/services/auth_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthService authService;

  ProfileBloc({required this.authService}) : super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<LogoutSubmittedEvent>(_onLogout);
  }

  Future<void> _onLoadProfile(
      LoadProfileEvent event, Emitter<ProfileState> emit) async {
    debugPrint('👉 [BLOC: PROFILE] LoadProfileEvent received');
    emit(const ProfileLoading());
    try {
      final user = await authService.getCurrentUser();
      if (user != null) {
        debugPrint('🎯 [BLOC: PROFILE] User loaded: ${user.name} (${user.id})');
        emit(ProfileLoaded(employee: user));
      } else {
        debugPrint('⚠️ [BLOC: PROFILE] No logged in user found');
        emit(const ProfileError(message: 'No logged in user found'));
      }
    } catch (e) {
      debugPrint('❌ [BLOC: PROFILE] Error: $e');
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onLogout(
      LogoutSubmittedEvent event, Emitter<ProfileState> emit) async {
    debugPrint('👉 [BLOC: PROFILE] LogoutSubmittedEvent received');
    await authService.logout();
    debugPrint('🎯 [BLOC: PROFILE] User logged out successfully. Emitting ProfileLoggedOut');
    emit(const ProfileLoggedOut());
  }
}
