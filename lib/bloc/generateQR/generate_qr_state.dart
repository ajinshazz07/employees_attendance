part of 'generate_qr_bloc.dart';

@immutable
sealed class GenerateQrState {
  const GenerateQrState();
}

final class GenerateQrInitial extends GenerateQrState {
  const GenerateQrInitial();
}

final class GenerateQrLoading extends GenerateQrState {
  const GenerateQrLoading();
}

final class GenerateQrSuccess extends GenerateQrState {
  final QrSessionModel session;
  final String qrDataString;

  const GenerateQrSuccess({
    required this.session,
    required this.qrDataString,
  });
}

final class GenerateQrError extends GenerateQrState {
  final String errorMessage;

  const GenerateQrError({required this.errorMessage});
}
