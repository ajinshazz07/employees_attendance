part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardEvent {
  const DashboardEvent();
}

final class LoadDashboardEvent extends DashboardEvent {
  const LoadDashboardEvent();
}

final class RefreshDashboardEvent extends DashboardEvent {
  const RefreshDashboardEvent();
}
