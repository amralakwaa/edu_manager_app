/// ========================================
/// attendance_model.dart - نموذج الحضور والغياب
/// نظام إدارة التعليم / Education Management System
/// ========================================
///
/// نموذج سجل الحضور والغياب

import 'dart:convert';
import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

/// حالة الحضور / Attendance Status
enum AttendanceStatus {
  present, // حاضر
  absent, // غائب
  late, // متأخر
  excused, // غياب بعذر
}

/// نموذج الحضور / Attendance Model
@HiveType(typeId: 7)
class AttendanceModel extends HiveObject {
  /// معرف السجل الفريد
  @HiveField(0)
  final String id;

  /// معرف الطالب
  @HiveField(1)
  final String studentId;

  /// اسم الطالب (للعرض)
  @HiveField(2)
  final String? studentName;

  /// معرف المادة
  @HiveField(3)
  final String materialId;

  /// اسم المادة (للعرض)
  @HiveField(4)
  final String? materialName;

  /// معرف المعلم
  @HiveField(5)
  final String teacherId;

  /// تاريخ الحضور
  @HiveField(6)
  final DateTime date;

  /// حالة الحضور
  @HiveField(7)
  final String status;

  /// ملاحظات
  @HiveField(8)
  final String? notes;

  /// وقت الحضور (للمتأخرين)
  @HiveField(9)
  final String? checkInTime;

  /// تاريخ الإنشاء
  @HiveField(10)
  final DateTime createdAt;

  /// تاريخ آخر تحديث
  @HiveField(11)
  final DateTime updatedAt;

  /// Constructor
  AttendanceModel({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.materialId,
    this.materialName,
    required this.teacherId,
    required this.date,
    required this.status,
    this.notes,
    this.checkInTime,
    required this.createdAt,
    required this.updatedAt,
  });

  /// نسخة معدلة
  AttendanceModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? materialId,
    String? materialName,
    String? teacherId,
    DateTime? date,
    String? status,
    String? notes,
    String? checkInTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      teacherId: teacherId ?? this.teacherId,
      date: date ?? this.date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      checkInTime: checkInTime ?? this.checkInTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'material_id': materialId,
      'material_name': materialName,
      'teacher_id': teacherId,
      'date': date.toIso8601String().split('T').first,
      'status': status,
      'notes': notes,
      'check_in_time': checkInTime,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// إنشاء من Map
  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] ?? '',
      studentId: map['student_id'] ?? '',
      studentName: map['student_name'],
      materialId: map['material_id'] ?? '',
      materialName: map['material_name'],
      teacherId: map['teacher_id'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      status: map['status'] ?? 'absent',
      notes: map['notes'],
      checkInTime: map['check_in_time'],
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'])
              : DateTime.now(),
      updatedAt:
          map['updated_at'] != null
              ? DateTime.parse(map['updated_at'])
              : DateTime.now(),
    );
  }

  /// تحويل إلى JSON
  String toJson() => json.encode(toMap());

  /// إنشاء من JSON
  factory AttendanceModel.fromJson(String source) =>
      AttendanceModel.fromMap(json.decode(source));

  /// هل الطالب حاضر؟
  bool get isPresent => status == 'present';

  /// هل الطالب غائب؟
  bool get isAbsent => status == 'absent';

  /// هل الطالب متأخر؟
  bool get isLate => status == 'late';

  /// الحالة بالعربية
  String get statusAr {
    switch (status) {
      case 'present':
        return 'حاضر';
      case 'absent':
        return 'غائب';
      case 'late':
        return 'متأخر';
      case 'excused':
        return 'غياب بعذر';
      default:
        return status;
    }
  }

  @override
  String toString() {
    return 'AttendanceModel(id: $id, studentId: $studentId, date: $date, status: $status)';
  }
}

/// ملخص حضور الطالب / Student Attendance Summary
class AttendanceSummary {
  final String studentId;
  final String studentName;
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int excusedDays;

  AttendanceSummary({
    required this.studentId,
    required this.studentName,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.excusedDays,
  });

  /// نسبة الحضور
  double get attendancePercentage {
    if (totalDays == 0) return 0;
    return ((presentDays + lateDays) / totalDays) * 100;
  }

  /// نسبة الغياب
  double get absencePercentage {
    if (totalDays == 0) return 0;
    return (absentDays / totalDays) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'total_days': totalDays,
      'present_days': presentDays,
      'absent_days': absentDays,
      'late_days': lateDays,
      'excused_days': excusedDays,
      'attendance_percentage': attendancePercentage,
    };
  }

  factory AttendanceSummary.fromMap(Map<String, dynamic> map) {
    return AttendanceSummary(
      studentId: map['student_id'] ?? '',
      studentName: map['student_name'] ?? '',
      totalDays: map['total_days'] ?? 0,
      presentDays: map['present_days'] ?? 0,
      absentDays: map['absent_days'] ?? 0,
      lateDays: map['late_days'] ?? 0,
      excusedDays: map['excused_days'] ?? 0,
    );
  }
}
