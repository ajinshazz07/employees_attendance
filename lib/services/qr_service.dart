import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/models/qrSessionModel.dart';

class QrService {
  final _uuid = const Uuid();
  static const String _secretSalt = 'attendance_app_secure_salt_2026';

  QrSessionModel generateQrSession(String adminId) {
    final sessionId = _uuid.v4();
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(seconds: AppConstants.qrExpirySeconds));
    return QrSessionModel(
      sessionId: sessionId,
      adminId: adminId,
      createdAt: now,
      expiresAt: expiresAt,
    );
  }

  String encodeQrData(QrSessionModel session) {
    final payload = '${session.sessionId}|${session.expiresAt.millisecondsSinceEpoch}|${session.adminId}';
    final signature = sha256.convert(utf8.encode('$payload|$_secretSalt')).toString().substring(0, 10);
    return '$payload|$signature';
  }

  QrSessionModel? decodeAndValidateQrData(String qrData) {
    try {
      final parts = qrData.split('|');
      if (parts.length != 4) return null;

      final sessionId = parts[0];
      final expiresMs = int.tryParse(parts[1]);
      final adminId = parts[2];
      final signature = parts[3];

      if (expiresMs == null) return null;

      final payload = '$sessionId|$expiresMs|$adminId';
      final expectedSignature = sha256.convert(utf8.encode('$payload|$_secretSalt')).toString().substring(0, 10);

      if (signature != expectedSignature) return null;

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresMs);
      if (DateTime.now().isAfter(expiresAt)) return null;

      return QrSessionModel(
        sessionId: sessionId,
        adminId: adminId,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
      );
    } catch (_) {
      return null;
    }
  }
}

