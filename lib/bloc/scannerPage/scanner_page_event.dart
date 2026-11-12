part of 'scanner_page_bloc.dart';

@immutable
sealed class ScannerPageEvent {
  const ScannerPageEvent();
}

final class ProcessScannedQrEvent extends ScannerPageEvent {
  final String qrData;

  const ProcessScannedQrEvent({required this.qrData});
}

final class ResetScannerStateEvent extends ScannerPageEvent {
  const ResetScannerStateEvent();
}
