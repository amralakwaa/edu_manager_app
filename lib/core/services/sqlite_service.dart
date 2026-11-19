/// ========================================
/// sqlite_service.dart - خدمة SQLite
/// نظام إدارة التعليم / Education Management System
/// ========================================
///
/// إدارة الإحصائيات والتحليلات باستخدام SQLite

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../data/models/stats_model.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/grade_model.dart';

/// خدمة SQLite للإحصائيات والتحليلات
class SqliteService {
  static final SqliteService _instance = SqliteService._internal();
  factory SqliteService() => _instance;
  SqliteService._internal();

  Database? _database;
  bool _isInitialized = false;

  /// اسم قاعدة البيانات
  static const String _databaseName = 'edu_manager.db';
  static const int _databaseVersion = 1;

  /// تهيئة SQLite
  Future<void> init() async {
    if (_isInitialized) return;

    // SQLite غير مدعوم على الويب
    if (kIsWeb) {
      print('⚠️ SQLite is not supported on Web. Using alternative storage.');
      _isInitialized = true;
      return;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _isInitialized = true;
    print('✅ SQLite initialized successfully');
  }

  /// إنشاء الجداول
  Future<void> _onCreate(Database db, int version) async {
    // جدول الإحصائيات
    await db.execute('''
      CREATE TABLE stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        user_id TEXT,
        user_role TEXT,
        count INTEGER NOT NULL DEFAULT 0,
        average REAL,
        max_value REAL,
        min_value REAL,
        total REAL,
        metadata TEXT,
        recorded_at TEXT NOT NULL,
        period TEXT DEFAULT 'daily'
      )
    ''');

    // جدول سجل تسجيلات الدخول
    await db.execute('''
      CREATE TABLE login_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        user_role TEXT NOT NULL,
        device_id TEXT,
        ip_address TEXT,
        login_at TEXT NOT NULL,
        logout_at TEXT
      )
    ''');

    // جدول الأداء (ملخصات)
    await db.execute('''
      CREATE TABLE performance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT NOT NULL,
        material_id TEXT NOT NULL,
        grade_average REAL,
        attendance_rate REAL,
        assignment_completion REAL,
        semester TEXT,
        academic_year TEXT,
        recorded_at TEXT NOT NULL
      )
    ''');

    // جدول الحضور والغياب (سجلات فردية)
    await db.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        material_id TEXT NOT NULL,
        teacher_id TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        check_in_time TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // جدول الدرجات (سجلات فردية)
    await db.execute('''
      CREATE TABLE grades (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        material_id TEXT NOT NULL,
        teacher_id TEXT NOT NULL,
        grade_type TEXT NOT NULL,
        title TEXT NOT NULL,
        score REAL NOT NULL,
        total_marks REAL NOT NULL,
        percentage REAL NOT NULL,
        notes TEXT,
        graded_at TEXT NOT NULL,
        semester TEXT NOT NULL,
        academic_year TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // الفهارس لتسريع البحث
    await db.execute('CREATE INDEX idx_stats_type ON stats(type)');
    await db.execute('CREATE INDEX idx_stats_user ON stats(user_id)');
    await db.execute('CREATE INDEX idx_stats_date ON stats(recorded_at)');
    await db.execute('CREATE INDEX idx_login_user ON login_logs(user_id)');
    await db.execute(
      'CREATE INDEX idx_perf_student ON performance(student_id)',
    );
    await db.execute('CREATE INDEX idx_att_student ON attendance(student_id)');
    await db.execute(
      'CREATE INDEX idx_att_material ON attendance(material_id)',
    );
    await db.execute('CREATE INDEX idx_att_date ON attendance(date)');
    await db.execute('CREATE INDEX idx_grades_student ON grades(student_id)');
    await db.execute('CREATE INDEX idx_grades_material ON grades(material_id)');

    print('✅ SQLite tables created successfully');
  }

  /// ترقية قاعدة البيانات
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // ترقيات مستقبلية
  }

  /// الحصول على قاعدة البيانات
  Database get database {
    if (!_isInitialized || _database == null) {
      throw Exception('SQLite not initialized. Call init() first.');
    }
    return _database!;
  }

  // ===== عمليات الإحصائيات / Stats Operations =====

  /// إضافة إحصائية جديدة
  Future<int> insertStats(StatsModel stats) async {
    if (kIsWeb) return -1;
    return await database.insert('stats', stats.toMapForInsert());
  }

  /// الحصول على إحصائيات حسب النوع
  Future<List<StatsModel>> getStatsByType(String type) async {
    if (kIsWeb) return [];

    final List<Map<String, dynamic>> maps = await database.query(
      'stats',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'recorded_at DESC',
    );
    return maps.map((map) => StatsModel.fromMap(map)).toList();
  }

  /// الحصول على إحصائيات مستخدم
  Future<List<StatsModel>> getUserStats(String userId) async {
    if (kIsWeb) return [];

    final List<Map<String, dynamic>> maps = await database.query(
      'stats',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'recorded_at DESC',
    );
    return maps.map((map) => StatsModel.fromMap(map)).toList();
  }

  /// الحصول على إحصائيات فترة معينة
  Future<List<StatsModel>> getStatsByDateRange(
    DateTime start,
    DateTime end, {
    String? type,
  }) async {
    if (kIsWeb) return [];

    String where = 'recorded_at BETWEEN ? AND ?';
    List<dynamic> args = [start.toIso8601String(), end.toIso8601String()];

    if (type != null) {
      where += ' AND type = ?';
      args.add(type);
    }

    final List<Map<String, dynamic>> maps = await database.query(
      'stats',
      where: where,
      whereArgs: args,
      orderBy: 'recorded_at DESC',
    );
    return maps.map((map) => StatsModel.fromMap(map)).toList();
  }

  /// الحصول على ملخص الإحصائيات
  Future<Map<String, dynamic>> getStatsSummary() async {
    if (kIsWeb) {
      return {
        'total_logins': 0,
        'total_grades': 0,
        'avg_grade': 0.0,
        'attendance_rate': 0.0,
      };
    }

    // إجمالي تسجيلات الدخول اليوم
    final today = DateTime.now().toIso8601String().split('T').first;
    final loginsResult = await database.rawQuery(
      '''
      SELECT COUNT(*) as count FROM login_logs 
      WHERE date(login_at) = date(?)
    ''',
      [today],
    );

    // متوسط الدرجات
    final gradesResult = await database.rawQuery('''
      SELECT AVG(average) as avg FROM stats WHERE type = 'grade'
    ''');

    // معدل الحضور
    final attendanceResult = await database.rawQuery('''
      SELECT AVG(average) as avg FROM stats WHERE type = 'attendance'
    ''');

    return {
      'total_logins': loginsResult.first['count'] ?? 0,
      'avg_grade': gradesResult.first['avg'] ?? 0.0,
      'attendance_rate': attendanceResult.first['avg'] ?? 0.0,
    };
  }

  // ===== عمليات تسجيل الدخول / Login Operations =====

  /// تسجيل عملية دخول
  Future<int> logLogin({
    required String userId,
    required String userRole,
    String? deviceId,
    String? ipAddress,
  }) async {
    if (kIsWeb) return -1;

    return await database.insert('login_logs', {
      'user_id': userId,
      'user_role': userRole,
      'device_id': deviceId,
      'ip_address': ipAddress,
      'login_at': DateTime.now().toIso8601String(),
    });
  }

  /// تسجيل عملية خروج
  Future<void> logLogout(int loginId) async {
    if (kIsWeb) return;

    await database.update(
      'login_logs',
      {'logout_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [loginId],
    );
  }

  /// الحصول على سجل تسجيلات الدخول
  Future<List<Map<String, dynamic>>> getLoginLogs({
    String? userId,
    int limit = 50,
  }) async {
    if (kIsWeb) return [];

    return await database.query(
      'login_logs',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'login_at DESC',
      limit: limit,
    );
  }

  // ===== عمليات الأداء / Performance Operations =====

  /// حفظ تقييم أداء الطالب
  Future<int> savePerformance({
    required String studentId,
    required String materialId,
    double? gradeAverage,
    double? attendanceRate,
    double? assignmentCompletion,
    String? semester,
    String? academicYear,
  }) async {
    if (kIsWeb) return -1;

    return await database.insert('performance', {
      'student_id': studentId,
      'material_id': materialId,
      'grade_average': gradeAverage,
      'attendance_rate': attendanceRate,
      'assignment_completion': assignmentCompletion,
      'semester': semester,
      'academic_year': academicYear,
      'recorded_at': DateTime.now().toIso8601String(),
    });
  }

  /// الحصول على أداء طالب
  Future<List<Map<String, dynamic>>> getStudentPerformance(
    String studentId,
  ) async {
    if (kIsWeb) return [];

    return await database.query(
      'performance',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'recorded_at DESC',
    );
  }

  // ===== عمليات الحضور / Attendance Operations =====

  /// حفظ سجل حضور
  Future<void> insertAttendance(AttendanceModel attendance) async {
    if (kIsWeb) return;
    await database.insert(
      'attendance',
      attendance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// الحصول على حضور مادة في تاريخ معين
  Future<List<AttendanceModel>> getAttendanceByDate(
    String materialId,
    DateTime date,
  ) async {
    if (kIsWeb) return [];
    final dateStr = date.toIso8601String().split('T').first;

    final List<Map<String, dynamic>> maps = await database.query(
      'attendance',
      where: 'material_id = ? AND date = ?',
      whereArgs: [materialId, dateStr],
    );
    return maps.map((map) => AttendanceModel.fromMap(map)).toList();
  }

  /// الحصول على سجل حضور طالب
  Future<List<AttendanceModel>> getStudentAttendance(String studentId) async {
    if (kIsWeb) return [];
    final List<Map<String, dynamic>> maps = await database.query(
      'attendance',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => AttendanceModel.fromMap(map)).toList();
  }

  // ===== عمليات الدرجات / Grades Operations =====

  /// حفظ درجة
  Future<void> insertGrade(GradeModel grade) async {
    if (kIsWeb) return;
    await database.insert(
      'grades',
      grade.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// الحصول على درجات طالب
  Future<List<GradeModel>> getStudentGrades(String studentId) async {
    if (kIsWeb) return [];
    final List<Map<String, dynamic>> maps = await database.query(
      'grades',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'graded_at DESC',
    );
    return maps.map((map) => GradeModel.fromMap(map)).toList();
  }

  /// الحصول على درجات مادة
  Future<List<GradeModel>> getMaterialGrades(String materialId) async {
    if (kIsWeb) return [];
    final List<Map<String, dynamic>> maps = await database.query(
      'grades',
      where: 'material_id = ?',
      whereArgs: [materialId],
      orderBy: 'graded_at DESC',
    );
    return maps.map((map) => GradeModel.fromMap(map)).toList();
  }

  // ===== عمليات عامة / General Operations =====

  /// تنفيذ استعلام خام
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    if (kIsWeb) return [];
    return await database.rawQuery(sql, args);
  }

  /// حذف سجلات قديمة
  Future<void> cleanOldRecords({int daysToKeep = 90}) async {
    if (kIsWeb) return;

    final cutoffDate =
        DateTime.now().subtract(Duration(days: daysToKeep)).toIso8601String();

    await database.delete(
      'stats',
      where: 'recorded_at < ?',
      whereArgs: [cutoffDate],
    );

    await database.delete(
      'login_logs',
      where: 'login_at < ?',
      whereArgs: [cutoffDate],
    );
  }

  /// إغلاق قاعدة البيانات
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
    }
  }
}
