class QrSessionModel {
  final String sessionId;
  final String adminId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;
  final String? usedByEmployeeId;

  const QrSessionModel({
    required this.sessionId,
    required this.adminId,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
    this.usedByEmployeeId,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && !isUsed;

  int get secondsRemaining {
    final diff = expiresAt.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  factory QrSessionModel.fromJson(Map<String, dynamic> json) => QrSessionModel(
        sessionId: json['session_id'] ?? '',
        adminId: json['admin_id'] ?? '',
        createdAt: DateTime.parse(json['created_at']),
        expiresAt: DateTime.parse(json['expires_at']),
        isUsed: (json['is_used'] == 1 || json['is_used'] == true),
        usedByEmployeeId: json['used_by'],
      );

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'admin_id': adminId,
        'created_at': createdAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'is_used': isUsed ? 1 : 0,
        'used_by': usedByEmployeeId,
      };
}

