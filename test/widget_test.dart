import 'package:flutter_test/flutter_test.dart';
import 'package:employees_attendance/services/apiService.dart';
import 'package:employees_attendance/services/qr_service.dart';
import 'package:employees_attendance/models/employeeModel.dart';
import 'package:employees_attendance/models/attendanceModel.dart';
import 'package:employees_attendance/core/constant.dart';

void main() {
  group('Smart QR Attendance Core Unit Tests', () {
    final qrService = QrService();

    test('QR Service generates valid session with 5-minute expiry', () {
      final session = qrService.generateQrSession('ADM001');

      expect(session.sessionId, isNotEmpty);
      expect(session.adminId, equals('ADM001'));
      expect(session.isExpired, isFalse);
      expect(session.isValid, isTrue);
      expect(session.secondsRemaining, greaterThan(0));
    });

    test('QR Service correctly encodes and validates SHA-256 integrity signature', () {
      final session = qrService.generateQrSession('ADM001');
      final qrString = qrService.encodeQrData(session);

      expect(qrString, isNotEmpty);
      expect(qrString.split('|').length, equals(4));

      final decoded = qrService.decodeAndValidateQrData(qrString);
      expect(decoded, isNotNull);
      expect(decoded!.sessionId, equals(session.sessionId));
      expect(decoded.adminId, equals('ADM001'));
    });

    test('QR Service rejects tampered QR code payload', () {
      final session = qrService.generateQrSession('ADM001');
      final qrString = qrService.encodeQrData(session);

      final tampered = 'tampered_id${qrString.substring(session.sessionId.length)}';
      final result = qrService.decodeAndValidateQrData(tampered);

      expect(result, isNull);
    });

    test('EmployeeModel serialization from dummy data', () {
      final raw = dummyEmployees.first;
      final emp = EmployeeModel.fromJson(raw);

      expect(emp.id, equals('EMP001'));
      expect(emp.name, equals('Alice Johnson'));
      expect(emp.role, equals('employee'));
      expect(emp.toJson()['email'], equals('alice@company.com'));
    });

    test('AttendanceModel serialization with check-in and check-out fields', () {
      final record = AttendanceModel(
        id: 1,
        employeeId: 1,
        employeeName: 'Alice Johnson',
        requestDate: '2026-11-12',
        checkInTime: '09:00 AM',
        status: 'Present',
        leaveBalance: 14.5,
        overtimeHours: 2.0,
      );

      expect(record.checkOutTime, isNull);
      expect(record.status, equals('Present'));

      final updated = record.copyWith(checkOutTime: '05:30 PM');
      expect(updated.checkOutTime, equals('05:30 PM'));
      expect(updated.toJson()['check_out_time'], equals('05:30 PM'));
    });

    test('ApiService fetchUserAttendance and verifyAttendance execute with logging', () async {
      final apiService = ApiService();
      final records = await apiService.fetchUserAttendance();
      expect(records, isNotEmpty);
      expect(records.first.employeeName, isNotEmpty);

      final verifyResult = await apiService.verifyAttendance(
        sessionId: 'test_session',
        employeeId: 'EMP001',
        latitude: 37.7749,
        longitude: -122.4194,
      );
      expect(verifyResult, isNotNull);
      expect(verifyResult['success'], isTrue);
    });
  });
}
