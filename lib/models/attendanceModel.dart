class AttendanceModel {
  int? id;
  int? employeeId;
  String? employeeName;
  double? leaveBalance;
  double? overtimeHours;
  int? attendanceCorrections;
  String? requestType;
  String? requestDate;
  String? status;
  String? checkInTime;
  String? checkOutTime;
  double? latitude;
  double? longitude;
  String? qrSessionId;

  AttendanceModel({
    this.id,
    this.employeeId,
    this.employeeName,
    this.leaveBalance,
    this.overtimeHours,
    this.attendanceCorrections,
    this.requestType,
    this.requestDate,
    this.status,
    this.checkInTime,
    this.checkOutTime,
    this.latitude,
    this.longitude,
    this.qrSessionId,
  });

  AttendanceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    employeeId = json['employee_id'] is int
        ? json['employee_id']
        : int.tryParse(json['employee_id']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '');
    employeeName = json['employee_name'];
    leaveBalance = (json['leave_balance'] as num?)?.toDouble();
    overtimeHours = (json['overtime_hours'] as num?)?.toDouble();
    attendanceCorrections = json['attendance_corrections'];
    requestType = json['request_type'];
    requestDate = json['request_date'] ?? json['date'];
    status = json['status'];
    checkInTime = json['check_in_time'];
    checkOutTime = json['check_out_time'];
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
    qrSessionId = json['qr_session_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employee_id'] = employeeId;
    data['employee_name'] = employeeName;
    data['leave_balance'] = leaveBalance;
    data['overtime_hours'] = overtimeHours;
    data['attendance_corrections'] = attendanceCorrections;
    data['request_type'] = requestType;
    data['request_date'] = requestDate;
    data['status'] = status;
    data['check_in_time'] = checkInTime;
    data['check_out_time'] = checkOutTime;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['qr_session_id'] = qrSessionId;
    return data;
  }

  AttendanceModel copyWith({
    int? id,
    int? employeeId,
    String? employeeName,
    double? leaveBalance,
    double? overtimeHours,
    int? attendanceCorrections,
    String? requestType,
    String? requestDate,
    String? status,
    String? checkInTime,
    String? checkOutTime,
    double? latitude,
    double? longitude,
    String? qrSessionId,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      leaveBalance: leaveBalance ?? this.leaveBalance,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      attendanceCorrections: attendanceCorrections ?? this.attendanceCorrections,
      requestType: requestType ?? this.requestType,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      qrSessionId: qrSessionId ?? this.qrSessionId,
    );
  }
}
