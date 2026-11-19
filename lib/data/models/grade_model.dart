/// ========================================
/// grade_model.dart - نموذج الدرجات
/// نظام إدارة التعليم / Education Management System
/// ========================================
///
/// نموذج الدرجات مع دعم الكاش

import 'dart:convert';
import 'package:hive/hive.dart';

part 'grade_model.g.dart';

/// نوع التقييم / Grade Type
enum GradeType {
  midterm, // نصف الفصل
  final_exam, // النهائي
  quiz, // اختبار قصير
  assignment, // واجب
  project, // مشروع
  participation, // مشاركة
}

/// نموذج الدرجة / Grade Model
@HiveType(typeId: 6)
class GradeModel extends HiveObject {
  /// معرف الدرجة الفريد
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

  /// نوع التقييم
  @HiveField(6)
  final String gradeType;

  /// عنوان التقييم
  @HiveField(7)
  final String title;

  /// الدرجة المحصلة
  @HiveField(8)
  final double score;

  /// الدرجة الكاملة
  @HiveField(9)
  final double totalMarks;

  /// النسبة المئوية
  @HiveField(10)
  final double percentage;

  /// ملاحظات المعلم
  @HiveField(11)
  final String? notes;

  /// تاريخ التقييم
  @HiveField(12)
  final DateTime gradedAt;

  /// الفصل الدراسي
  @HiveField(13)
  final String semester;

  /// السنة الدراسية
  @HiveField(14)
  final String academicYear;

  /// تاريخ آخر تحديث
  @HiveField(15)
  final DateTime updatedAt;

  /// Constructor
  GradeModel({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.materialId,
    this.materialName,
    required this.teacherId,
    required this.gradeType,
    required this.title,
    required this.score,
    required this.totalMarks,
    double? percentage,
    this.notes,
    required this.gradedAt,
    required this.semester,
    required this.academicYear,
    required this.updatedAt,
  }) : percentage = percentage ?? (score / totalMarks * 100);

  /// نسخة معدلة
  GradeModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? materialId,
    String? materialName,
    String? teacherId,
    String? gradeType,
    String? title,
    double? score,
    double? totalMarks,
    double? percentage,
    String? notes,
    DateTime? gradedAt,
    String? semester,
    String? academicYear,
    DateTime? updatedAt,
  }) {
    return GradeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      teacherId: teacherId ?? this.teacherId,
      gradeType: gradeType ?? this.gradeType,
      title: title ?? this.title,
      score: score ?? this.score,
      totalMarks: totalMarks ?? this.totalMarks,
      percentage: percentage ?? this.percentage,
      notes: notes ?? this.notes,
      gradedAt: gradedAt ?? this.gradedAt,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
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
      'grade_type': gradeType,
      'title': title,
      'score': score,
      'total_marks': totalMarks,
      'percentage': percentage,
      'notes': notes,
      'graded_at': gradedAt.toIso8601String(),
      'semester': semester,
      'academic_year': academicYear,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// إنشاء من Map
  factory GradeModel.fromMap(Map<String, dynamic> map) {
    final score = (map['score'] ?? 0).toDouble();
    final totalMarks = (map['total_marks'] ?? 100).toDouble();

    return GradeModel(
      id: map['id'] ?? '',
      studentId: map['student_id'] ?? '',
      studentName: map['student_name'],
      materialId: map['material_id'] ?? '',
      materialName: map['material_name'],
      teacherId: map['teacher_id'] ?? '',
      gradeType: map['grade_type'] ?? 'quiz',
      title: map['title'] ?? '',
      score: score,
      totalMarks: totalMarks,
      percentage: map['percentage']?.toDouble() ?? (score / totalMarks * 100),
      notes: map['notes'],
      gradedAt:
          map['graded_at'] != null
              ? DateTime.parse(map['graded_at'])
              : DateTime.now(),
      semester: map['semester'] ?? '',
      academicYear: map['academic_year'] ?? '',
      updatedAt:
          map['updated_at'] != null
              ? DateTime.parse(map['updated_at'])
              : DateTime.now(),
    );
  }

  /// تحويل إلى JSON
  String toJson() => json.encode(toMap());

  /// إنشاء من JSON
  factory GradeModel.fromJson(String source) =>
      GradeModel.fromMap(json.decode(source));

  /// هل الطالب ناجح؟
  bool get isPassing => percentage >= 50;

  /// تقدير الدرجة
  String get letterGrade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 85) return 'A';
    if (percentage >= 80) return 'B+';
    if (percentage >= 75) return 'B';
    if (percentage >= 70) return 'C+';
    if (percentage >= 65) return 'C';
    if (percentage >= 60) return 'D+';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  /// تقدير بالعربية
  String get letterGradeAr {
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 80) return 'جيد جداً';
    if (percentage >= 70) return 'جيد';
    if (percentage >= 60) return 'مقبول';
    if (percentage >= 50) return 'ضعيف';
    return 'راسب';
  }

  @override
  String toString() {
    return 'GradeModel(id: $id, score: $score/$totalMarks, grade: $letterGrade)';
  }
}
