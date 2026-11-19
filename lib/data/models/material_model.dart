// ========================================
// material_model.dart - نموذج المادة الدراسية
// نظام إدارة التعليم / Education Management System
// ========================================
//
// نموذج المادة الدراسية مع تفاصيلها

import 'dart:convert';
import 'package:hive/hive.dart';

part 'material_model.g.dart';

/// نموذج المادة الدراسية / Material Model
@HiveType(typeId: 3)
class MaterialModel extends HiveObject {
  /// معرف المادة الفريد
  @HiveField(0)
  final String id;

  /// اسم المادة
  @HiveField(1)
  final String name;

  /// رمز المادة
  @HiveField(2)
  final String code;

  /// وصف المادة
  @HiveField(3)
  final String? description;

  /// المعلم المسؤول
  @HiveField(4)
  final String teacherId;

  /// اسم المعلم (للعرض)
  @HiveField(5)
  final String? teacherName;

  /// المرحلة / الصف
  @HiveField(6)
  final String grade;

  /// الفصل الدراسي
  @HiveField(7)
  final String semester;

  /// عدد الساعات المعتمدة
  @HiveField(8)
  final int creditHours;

  /// الدرجة الكاملة
  @HiveField(9)
  final double totalMarks;

  /// درجة النجاح
  @HiveField(10)
  final double passingMarks;

  /// الأيام (مثل: السبت، الأحد)
  @HiveField(11)
  final List<String> days;

  /// وقت البداية
  @HiveField(12)
  final String? startTime;

  /// وقت النهاية
  @HiveField(13)
  final String? endTime;

  /// حالة المادة
  @HiveField(14)
  final String status;

  /// تاريخ الإنشاء
  @HiveField(15)
  final DateTime createdAt;

  /// تاريخ آخر تحديث
  @HiveField(16)
  final DateTime updatedAt;

  /// وقت انتهاء الصلاحية في الكاش (TTL)
  @HiveField(17)
  final DateTime? cacheExpiresAt;

  /// Constructor
  MaterialModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.teacherId,
    this.teacherName,
    required this.grade,
    required this.semester,
    this.creditHours = 3,
    this.totalMarks = 100,
    this.passingMarks = 50,
    this.days = const [],
    this.startTime,
    this.endTime,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.cacheExpiresAt,
  });

  /// نسخة معدلة
  MaterialModel copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? teacherId,
    String? teacherName,
    String? grade,
    String? semester,
    int? creditHours,
    double? totalMarks,
    double? passingMarks,
    List<String>? days,
    String? startTime,
    String? endTime,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cacheExpiresAt,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      grade: grade ?? this.grade,
      semester: semester ?? this.semester,
      creditHours: creditHours ?? this.creditHours,
      totalMarks: totalMarks ?? this.totalMarks,
      passingMarks: passingMarks ?? this.passingMarks,
      days: days ?? this.days,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheExpiresAt: cacheExpiresAt ?? this.cacheExpiresAt,
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'grade': grade,
      'semester': semester,
      'credit_hours': creditHours,
      'total_marks': totalMarks,
      'passing_marks': passingMarks,
      'days': days,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cache_expires_at': cacheExpiresAt?.toIso8601String(),
    };
  }

  /// إنشاء من Map
  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      description: map['description'],
      teacherId: map['teacher_id'] ?? '',
      teacherName: map['teacher_name'],
      grade: map['grade'] ?? '',
      semester: map['semester'] ?? '',
      creditHours: map['credit_hours'] ?? 3,
      totalMarks: (map['total_marks'] ?? 100).toDouble(),
      passingMarks: (map['passing_marks'] ?? 50).toDouble(),
      days: List<String>.from(map['days'] ?? []),
      startTime: map['start_time'],
      endTime: map['end_time'],
      status: map['status'] ?? 'active',
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'])
              : DateTime.now(),
      updatedAt:
          map['updated_at'] != null
              ? DateTime.parse(map['updated_at'])
              : DateTime.now(),
      cacheExpiresAt:
          map['cache_expires_at'] != null
              ? DateTime.parse(map['cache_expires_at'])
              : null,
    );
  }

  /// تحويل إلى JSON
  String toJson() => json.encode(toMap());

  /// إنشاء من JSON
  factory MaterialModel.fromJson(String source) =>
      MaterialModel.fromMap(json.decode(source));

  /// هل الكاش منتهي الصلاحية؟
  bool get isCacheExpired {
    if (cacheExpiresAt == null) return true;
    return DateTime.now().isAfter(cacheExpiresAt!);
  }

  /// تعيين TTL للكاش (بالدقائق)
  MaterialModel withCacheTTL(int minutes) {
    return copyWith(
      cacheExpiresAt: DateTime.now().add(Duration(minutes: minutes)),
    );
  }

  @override
  String toString() {
    return 'MaterialModel(id: $id, name: $name, code: $code)';
  }
}
