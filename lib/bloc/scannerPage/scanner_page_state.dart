part of 'scanner_page_bloc.dart';

@immutable
sealed class ScannerPageState {
  const ScannerPageState();
}

final class ScannerPageInitial extends ScannerPageState {
  const ScannerPageInitial();
}

final class ScannerPageProcessing extends ScannerPageState {
  const ScannerPageProcessing();
}

final class ScannerPageSuccess extends ScannerPageState {
  final String message;
  final bool isCheckIn;
  final String timestamp;

  const ScannerPageSuccess({
    required this.message,
    required this.isCheckIn,
    required this.timestamp,
  });
}

final class ScannerPageFailure extends ScannerPageState {
  final String errorMessage;

  const ScannerPageFailure({required this.errorMessage});
}
