part of 'generate_qr_bloc.dart';

@immutable
sealed class GenerateQrEvent {
  const GenerateQrEvent();
}

final class GenerateNewQrSessionEvent extends GenerateQrEvent {
  const GenerateNewQrSessionEvent();
}

final class RefreshQrSessionEvent extends GenerateQrEvent {
  const RefreshQrSessionEvent();
}
