import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/models/attendanceModel.dart';
import 'package:employees_attendance/models/qrSessionModel.dart';

class LocalDatabaseService {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employee_id INTEGER NOT NULL,
            employee_name TEXT,
            leave_balance REAL,
            overtime_hours REAL,
            attendance_corrections INTEGER,
            request_type TEXT,
            request_date TEXT NOT NULL,
            status TEXT NOT NULL,
            check_in_time TEXT,
            check_out_time TEXT,
            latitude REAL,
            longitude REAL,
            qr_session_id TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE qr_sessions (
            session_id TEXT PRIMARY KEY,
            admin_id TEXT NOT NULL,
            created_at TEXT NOT NULL,
            expires_at TEXT NOT NULL,
            is_used INTEGER DEFAULT 0,
            used_by TEXT
          )
        ''');
      },
    );
  }

  // ── Attendance Operations ──────────────────────────────────────────

  Future<int> insertAttendance(AttendanceModel attendance) async {
    final db = await database;
    return await db.insert(
      'attendance',
      attendance.toJson()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AttendanceModel?> getTodayAttendance(int employeeId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.query(
      'attendance',
      where: 'employee_id = ? AND request_date = ?',
      whereArgs: [employeeId, today],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return AttendanceModel.fromJson(result.first);
  }

  Future<List<AttendanceModel>> getEmployeeAttendanceHistory(int employeeId,
      {String? fromDate, String? toDate}) async {
    final db = await database;
    String where = 'employee_id = ?';
    List<dynamic> args = [employeeId];

    if (fromDate != null) {
      where += ' AND request_date >= ?';
      args.add(fromDate);
    }
    if (toDate != null) {
      where += ' AND request_date <= ?';
      args.add(toDate);
    }

    final result = await db.query(
      'attendance',
      where: where,
      whereArgs: args,
      orderBy: 'request_date DESC, id DESC',
    );
    return result.map((e) => AttendanceModel.fromJson(e)).toList();
  }

  Future<List<AttendanceModel>> getAllAttendance({int? employeeId, String? date}) async {
    final db = await database;
    String? where;
    List<dynamic>? args;

    if (employeeId != null && date != null) {
      where = 'employee_id = ? AND request_date = ?';
      args = [employeeId, date];
    } else if (employeeId != null) {
      where = 'employee_id = ?';
      args = [employeeId];
    } else if (date != null) {
      where = 'request_date = ?';
      args = [date];
    }

    final result = await db.query(
      'attendance',
      where: where,
      whereArgs: args,
      orderBy: 'request_date DESC, id DESC',
    );
    return result.map((e) => AttendanceModel.fromJson(e)).toList();
  }

  Future<void> updateCheckOut(int recordId, String checkOutTime) async {
    final db = await database;
    await db.update(
      'attendance',
      {'check_out_time': checkOutTime},
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  // ── QR Session Operations ──────────────────────────────────────────

  Future<void> insertQrSession(QrSessionModel session) async {
    final db = await database;
    await db.insert(
      'qr_sessions',
      session.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isQrSessionUsed(String sessionId) async {
    final db = await database;
    final result = await db.query(
      'qr_sessions',
      where: 'session_id = ? AND is_used = 1',
      whereArgs: [sessionId],
    );
    return result.isNotEmpty;
  }

  Future<void> markQrSessionUsed(String sessionId, String employeeId) async {
    final db = await database;
    await db.update(
      'qr_sessions',
      {'is_used': 1, 'used_by': employeeId},
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<QrSessionModel?> getLatestActiveQrSession() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final result = await db.query(
      'qr_sessions',
      where: 'expires_at > ? AND is_used = 0',
      whereArgs: [now],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return QrSessionModel.fromJson(result.first);
  }
}

