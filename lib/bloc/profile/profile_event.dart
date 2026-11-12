part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {
  const ProfileEvent();
}

final class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

final class LogoutSubmittedEvent extends ProfileEvent {
  const LogoutSubmittedEvent();
}
