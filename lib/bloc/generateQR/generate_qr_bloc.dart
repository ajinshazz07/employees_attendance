import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:employees_attendance/models/qrSessionModel.dart';
import 'package:employees_attendance/services/auth_service.dart';
import 'package:employees_attendance/services/local_database_service.dart';
import 'package:employees_attendance/services/qr_service.dart';

part 'generate_qr_event.dart';
part 'generate_qr_state.dart';

class GenerateQrBloc extends Bloc<GenerateQrEvent, GenerateQrState> {
  final QrService qrService;
  final LocalDatabaseService dbService;
  final AuthService authService;

  GenerateQrBloc({
    required this.qrService,
    required this.dbService,
    required this.authService,
  }) : super(const GenerateQrInitial()) {
    on<GenerateNewQrSessionEvent>(_onGenerate);
    on<RefreshQrSessionEvent>(_onGenerate);
  }

  Future<void> _onGenerate(
      GenerateQrEvent event, Emitter<GenerateQrState> emit) async {
    debugPrint('👉 [BLOC: GENERATE QR] Generate/Refresh event received');
    emit(const GenerateQrLoading());
    try {
      final user = await authService.getCurrentUser();
      final adminId = user?.id ?? 'ADM001';

      debugPrint('🔐 [BLOC: GENERATE QR] Generating 5-min QR session with HMAC SHA-256 for admin: $adminId');
      final session = qrService.generateQrSession(adminId);
      final qrString = qrService.encodeQrData(session);

      await dbService.insertQrSession(session);
      debugPrint('✅ [BLOC: GENERATE QR] Session created: ${session.sessionId}, Payload: $qrString');

      emit(GenerateQrSuccess(
        session: session,
        qrDataString: qrString,
      ));
    } catch (e) {
      debugPrint('❌ [BLOC: GENERATE QR] Error generating QR: $e');
      emit(GenerateQrError(errorMessage: e.toString()));
    }
  }
}
