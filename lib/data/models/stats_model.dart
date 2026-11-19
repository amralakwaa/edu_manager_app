/// ========================================
/// stats_model.dart - نموذج الإحصائيات (SQLite)
/// نظام إدارة التعليم / Education Management System
/// ========================================
///
/// نموذج الإحصائيات المخزنة في SQLite

import 'dart:convert';

/// أنواع الإحصائيات / Stats Types
enum StatsType {
  login, // تسجيلات الدخول
  assignment, // الواجبات
  grade, // الدرجات
  attendance, // الحضور
  material, // المواد
  user, // المستخدمين
  sync, // المزامنة
}

/// نموذج الإحصائية / Stats Model
/// يُخزن في SQLite للتحليلات
class StatsModel {
  /// معرف الإحصائية (auto-increment)
  final int? id;

  /// نوع الإحصائية
  final String type;

  /// معرف المستخدم المرتبط (اختياري)
  final String? userId;

  /// صلاحية المستخدم
  final String? userRole;

  /// القيمة الرقمية
  final int count;

  /// المعدل (إن وجد)
  final double? average;

  /// أعلى قيمة
  final double? maxValue;

  /// أقل قيمة
  final double? minValue;

  /// المجموع
  final double? total;

  /// بيانات إضافية (JSON)
  final String? metadata;

  /// تاريخ التسجيل
  final DateTime recordedAt;

  /// الفترة (يومي، أسبوعي، شهري)
  final String period;

  /// Constructor
  StatsModel({
    this.id,
    required this.type,
    this.userId,
    this.userRole,
    required this.count,
    this.average,
    this.maxValue,
    this.minValue,
    this.total,
    this.metadata,
    required this.recordedAt,
    this.period = 'daily',
  });

  /// نسخة معدلة
  StatsModel copyWith({
    int? id,
    String? type,
    String? userId,
    String? userRole,
    int? count,
    double? average,
    double? maxValue,
    double? minValue,
    double? total,
    String? metadata,
    DateTime? recordedAt,
    String? period,
  }) {
    return StatsModel(
      id: id ?? this.id,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      count: count ?? this.count,
      average: average ?? this.average,
      maxValue: maxValue ?? this.maxValue,
      minValue: minValue ?? this.minValue,
      total: total ?? this.total,
      metadata: metadata ?? this.metadata,
      recordedAt: recordedAt ?? this.recordedAt,
      period: period ?? this.period,
    );
  }

  /// تحويل إلى Map للتخزين في SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'user_id': userId,
      'user_role': userRole,
      'count': count,
      'average': average,
      'max_value': maxValue,
      'min_value': minValue,
      'total': total,
      'metadata': metadata,
      'recorded_at': recordedAt.toIso8601String(),
      'period': period,
    };
  }

  /// تحويل بدون id (للإدراج)
  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  /// إنشاء من Map
  factory StatsModel.fromMap(Map<String, dynamic> map) {
    return StatsModel(
      id: map['id'],
      type: map['type'] ?? '',
      userId: map['user_id'],
      userRole: map['user_role'],
      count: map['count'] ?? 0,
      average: map['average']?.toDouble(),
      maxValue: map['max_value']?.toDouble(),
      minValue: map['min_value']?.toDouble(),
      total: map['total']?.toDouble(),
      metadata: map['metadata'],
      recordedAt:
          map['recorded_at'] != null
              ? DateTime.parse(map['recorded_at'])
              : DateTime.now(),
      period: map['period'] ?? 'daily',
    );
  }

  /// تحويل إلى JSON
  String toJson() => json.encode(toMap());

  /// إنشاء من JSON
  factory StatsModel.fromJson(String source) =>
      StatsModel.fromMap(json.decode(source));

  /// إحصائية تسجيل دخول
  factory StatsModel.login({required String userId, required String userRole}) {
    return StatsModel(
      type: 'login',
      userId: userId,
      userRole: userRole,
      count: 1,
      recordedAt: DateTime.now(),
    );
  }

  /// إحصائية درجات
  factory StatsModel.grades({
    String? userId,
    required int count,
    required double average,
    double? max,
    double? min,
  }) {
    return StatsModel(
      type: 'grade',
      userId: userId,
      count: count,
      average: average,
      maxValue: max,
      minValue: min,
      recordedAt: DateTime.now(),
    );
  }

  /// إحصائية حضور
  factory StatsModel.attendance({
    String? userId,
    required int present,
    required int absent,
    required int late,
  }) {
    return StatsModel(
      type: 'attendance',
      userId: userId,
      count: present + absent + late,
      metadata: json.encode({
        'present': present,
        'absent': absent,
        'late': late,
      }),
      recordedAt: DateTime.now(),
    );
  }

  /// الحصول على البيانات الإضافية كـ Map
  Map<String, dynamic>? get metadataMap {
    if (metadata == null) return null;
    try {
      return json.decode(metadata!);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'StatsModel(id: $id, type: $type, count: $count)';
  }
}

/// ملخص الإحصائيات للوحة التحكم
class DashboardStats {
  final int totalUsers;
  final int totalStudents;
  final int totalTeachers;
  final int totalMaterials;
  final int totalAssignments;
  final int pendingAssignments;
  final double averageGrade;
  final double attendanceRate;
  final int todayLogins;
  final int connectedDevices;

  DashboardStats({
    this.totalUsers = 0,
    this.totalStudents = 0,
    this.totalTeachers = 0,
    this.totalMaterials = 0,
    this.totalAssignments = 0,
    this.pendingAssignments = 0,
    this.averageGrade = 0,
    this.attendanceRate = 0,
    this.todayLogins = 0,
    this.connectedDevices = 0,
  });

  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      totalUsers: map['total_users'] ?? 0,
      totalStudents: map['total_students'] ?? 0,
      totalTeachers: map['total_teachers'] ?? 0,
      totalMaterials: map['total_materials'] ?? 0,
      totalAssignments: map['total_assignments'] ?? 0,
      pendingAssignments: map['pending_assignments'] ?? 0,
      averageGrade: (map['average_grade'] ?? 0).toDouble(),
      attendanceRate: (map['attendance_rate'] ?? 0).toDouble(),
      todayLogins: map['today_logins'] ?? 0,
      connectedDevices: map['connected_devices'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_users': totalUsers,
      'total_students': totalStudents,
      'total_teachers': totalTeachers,
      'total_materials': totalMaterials,
      'total_assignments': totalAssignments,
      'pending_assignments': pendingAssignments,
      'average_grade': averageGrade,
      'attendance_rate': attendanceRate,
      'today_logins': todayLogins,
      'connected_devices': connectedDevices,
    };
  }
}
