import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/models/attendanceModel.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: dummyUserAttendanceBaseUrl,
      connectTimeout: const Duration(seconds: 2),
      receiveTimeout: const Duration(seconds: 2),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer dummy_jwt_token';
        debugPrint('[API REQUEST] ${options.method} ${options.uri}');
        if (options.data != null) debugPrint('Body: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[API RESPONSE] ${response.statusCode} from ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (err, handler) {
        debugPrint('[API ERROR] ${err.response?.statusCode ?? "Network Error"}: ${err.message}');
        handler.resolve(Response(
          requestOptions: err.requestOptions,
          statusCode: 200,
          data: _fallbackData,
        ));
      },
    ));
  }

  Future<List<AttendanceModel>> fetchUserAttendance({int page = 1, int limit = 5}) async {
    try {
      final response = await _dio.get(
        dummyUserAttendanceEndpoint,
        queryParameters: {'_page': page, '_limit': limit},
      );

      final data = response.data;
      final list = data is List
          ? data
          : (data is Map && data['data'] is List)
              ? data['data'] as List
              : _fallbackData;

      return list
          .map((item) => AttendanceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[API EXCEPTION] fetchUserAttendance: $e');
      return _fallbackData.map((e) => AttendanceModel.fromJson(e)).toList();
    }
  }

  Future<Map<String, dynamic>> verifyAttendance({
    required String sessionId,
    required String employeeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/mock/employee-attendance-and-leave-management/verify',
        data: {
          'session_id': sessionId,
          'employee_id': employeeId,
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'success': true, 'message': 'Attendance marked successfully'};
    } catch (e) {
      debugPrint('[API EXCEPTION] verifyAttendance: $e');
      return {'success': true, 'message': 'Attendance verified (Offline)'};
    }
  }

  static final List<Map<String, dynamic>> _fallbackData = [
    {
      'id': 1,
      'employee_id': 1,
      'employee_name': 'Alice Johnson',
      'leave_balance': 14.5,
      'overtime_hours': 2.0,
      'request_date': DateTime.now().toIso8601String().split('T')[0],
      'status': 'Present',
      'check_in_time': '09:02 AM',
      'check_out_time': '05:30 PM',
    },
    {
      'id': 2,
      'employee_id': 2,
      'employee_name': 'Bob Smith',
      'leave_balance': 10.0,
      'overtime_hours': 0.0,
      'request_date': DateTime.now().toIso8601String().split('T')[0],
      'status': 'Present',
      'check_in_time': '09:15 AM',
      'check_out_time': '05:15 PM',
    },
    {
      'id': 3,
      'employee_id': 3,
      'employee_name': 'Carol White',
      'leave_balance': 18.0,
      'overtime_hours': 4.5,
      'request_date': DateTime.now().toIso8601String().split('T')[0],
      'status': 'Late',
      'check_in_time': '10:05 AM',
      'check_out_time': null,
    },
  ];
}
