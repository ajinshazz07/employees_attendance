import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/models/attendanceModel.dart';
import 'package:employees_attendance/services/apiService.dart';
import 'package:employees_attendance/services/auth_service.dart';
import 'package:employees_attendance/services/local_database_service.dart';
import 'package:employees_attendance/services/location_service.dart';
import 'package:employees_attendance/services/qr_service.dart';

part 'scanner_page_event.dart';
part 'scanner_page_state.dart';

class ScannerPageBloc extends Bloc<ScannerPageEvent, ScannerPageState> {
  final QrService qrService;
  final LocalDatabaseService dbService;
  final ApiService apiService;
  final LocationService locationService;
  final AuthService authService;

  ScannerPageBloc({
    required this.qrService,
    required this.dbService,
    required this.apiService,
    required this.locationService,
    required this.authService,
  }) : super(const ScannerPageInitial()) {
    on<ProcessScannedQrEvent>(_onProcessScan);
    on<ResetScannerStateEvent>((event, emit) => emit(const ScannerPageInitial()));
  }

  Future<void> _onProcessScan(
      ProcessScannedQrEvent event, Emitter<ScannerPageState> emit) async {
    debugPrint('\n┌──────────────────────── [BLOC: SCANNER PROCESSING] ───────────────');
    debugPrint('│ 🔍 Raw QR Data Payload: ${event.qrData}');
    emit(const ScannerPageProcessing());
    try {
      final user = await authService.getCurrentUser();
      if (user == null) {
        debugPrint('│ ❌ Session expired. No active user found.');
        debugPrint('└────────────────────────────────────────────────────────────────────\n');
        emit(const ScannerPageFailure(
            errorMessage: 'User session expired. Please sign in again.'));
        return;
      }

      final empNumericId = int.tryParse(
              user.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
          1;

      // 1. Validate QR Code Integrity & Expiration
      debugPrint('│ 🔐 1. Validating HMAC SHA-256 signature and 5-min expiration...');
      final session = qrService.decodeAndValidateQrData(event.qrData);
      if (session == null) {
        debugPrint('│ ❌ QR signature check or expiration failed.');
        debugPrint('└────────────────────────────────────────────────────────────────────\n');
        emit(const ScannerPageFailure(
            errorMessage:
                'Invalid or expired QR code. Please request admin to regenerate.'));
        return;
      }
      debugPrint('│ ✅ QR Validated: Session ID = ${session.sessionId}, Admin ID = ${session.adminId}');

      // 2. Prevent Duplicate Attendance via Same QR Session
      debugPrint('│ 🛡️ 2. Verifying anti-replay in SQLite database...');
      final isUsed = await dbService.isQrSessionUsed(session.sessionId);
      if (isUsed) {
        debugPrint('│ ❌ QR session ${session.sessionId} has already been marked as used.');
        debugPrint('└────────────────────────────────────────────────────────────────────\n');
        emit(const ScannerPageFailure(
            errorMessage: 'This QR session has already been used.'));
        return;
      }

      // 3. Capture & Validate GPS Location (Geofencing)
      debugPrint('│ 📍 3. Capturing and checking GPS coordinates against office geofence...');
      final position = await locationService.getCurrentPosition();
      final double lat = position?.latitude ?? AppConstants.officeLatitude;
      final double lng = position?.longitude ?? AppConstants.officeLongitude;
      debugPrint('│ 📍 Current Position: Lat=$lat, Lng=$lng');

      if (!locationService.isWithinOfficeRange(lat, lng)) {
        debugPrint('│ ❌ GPS outside acceptable office geofence range.');
        debugPrint('└────────────────────────────────────────────────────────────────────\n');
        emit(const ScannerPageFailure(
            errorMessage:
                'Location mismatch: You must be physically within office premises.'));
        return;
      }
      debugPrint('│ ✅ Geofence validation passed.');

      // 4. Determine Check-In or Check-Out
      final todayRecord = await dbService.getTodayAttendance(empNumericId);
      final now = DateTime.now();
      final timeStr = DateFormat('hh:mm a').format(now);
      final dateStr = DateFormat('yyyy-MM-dd').format(now);

      if (todayRecord == null) {
        // First scan of day -> Check In
        final int hour = now.hour;
        final String status = hour >= 10 ? 'Late' : 'Present';
        debugPrint('│ 🟢 4. Executing CHECK-IN (Status: $status, Time: $timeStr)...');

        final newRecord = AttendanceModel(
          employeeId: empNumericId,
          employeeName: user.name,
          requestDate: dateStr,
          checkInTime: timeStr,
          status: status,
          latitude: lat,
          longitude: lng,
          qrSessionId: session.sessionId,
          leaveBalance: 14.5,
          overtimeHours: 0.0,
          attendanceCorrections: 0,
          requestType: 'Regular',
        );

        await dbService.insertAttendance(newRecord);
        await dbService.markQrSessionUsed(session.sessionId, user.id);
        debugPrint('│ 💾 Inserted attendance into local SQLite DB.');

        // REST API verification via Dio
        debugPrint('│ 📡 Calling backend REST API verifyAttendance via Dio...');
        final apiResp = await apiService.verifyAttendance(
          sessionId: session.sessionId,
          employeeId: user.id,
          latitude: lat,
          longitude: lng,
        );
        debugPrint('│ 🎯 Backend API Verification Result: $apiResp');
        debugPrint('└────────────────────────────────────────────────────────────────────\n');

        emit(ScannerPageSuccess(
          message: 'Check-In recorded successfully as "$status".',
          isCheckIn: true,
          timestamp: timeStr,
        ));
      } else if (todayRecord.checkOutTime == null) {
        // Second scan of day -> Check Out
        debugPrint('│ 🔵 4. Executing CHECK-OUT (Time: $timeStr)...');
        await dbService.updateCheckOut(todayRecord.id!, timeStr);
        await dbService.markQrSessionUsed(session.sessionId, user.id);
        debugPrint('│ 💾 Updated checkout in SQLite DB.');

        debugPrint('│ 📡 Calling backend REST API verifyAttendance via Dio...');
        final apiResp = await apiService.verifyAttendance(
          sessionId: session.sessionId,
          employeeId: user.id,
          latitude: lat,
          longitude: lng,
        );
        debugPrint('│ 🎯 Backend API Verification Result: $apiResp');
        debugPrint('└────────────────────────────────────────────────────────────────────\n');

        emit(ScannerPageSuccess(
          message: 'Check-Out recorded successfully.',
          isCheckIn: false,
          timestamp: timeStr,
        ));
      } else {
        debugPrint('│ ⚠️ User already completed attendance for today.');
        debugPrint('└────────────────────────────────────────────────────────────────────\n');
        emit(const ScannerPageFailure(
            errorMessage:
                'You have already completed your attendance for today.'));
      }
    } catch (e) {
      debugPrint('│ ❌ ScannerBloc Error: $e');
      debugPrint('└────────────────────────────────────────────────────────────────────\n');
      emit(ScannerPageFailure(errorMessage: 'Attendance error: $e'));
    }
  }
}
