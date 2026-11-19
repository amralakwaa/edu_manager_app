// ========================================
// assignment_model.dart - نموذج الواجب
// نظام إدارة التعليم / Education Management System
// ========================================
//
// نموذج الواجبات مع دعم الكاش والـ TTL

import 'dart:convert';
import 'package:hive/hive.dart';

part 'assignment_model.g.dart';

/// حالة الواجب / Assignment Status
enum AssignmentStatus {
  draft, // مسودة
  published, // منشور
  closed, // مغلق
}

/// حالة تسليم الواجب / Submission Status
enum SubmissionStatus {
  notSubmitted, // لم يتم التسليم
  submitted, // تم التسليم
  late, // متأخر
  graded, // تم التقييم
}

/// نموذج الواجب / Assignment Model
@HiveType(typeId: 4)
class AssignmentModel extends HiveObject {
  /// معرف الواجب الفريد
  @HiveField(0)
  final String id;

  /// عنوان الواجب
  @HiveField(1)
  final String title;

  /// وصف الواجب
  @HiveField(2)
  final String description;

  /// معرف المادة
  @HiveField(3)
  final String materialId;

  /// اسم المادة (للعرض)
  @HiveField(4)
  final String? materialName;

  /// معرف المعلم
  @HiveField(5)
  final String teacherId;

  /// اسم المعلم (للعرض)
  @HiveField(6)
  final String? teacherName;

  /// المرحلة / الصف
  @HiveField(7)
  final String grade;

  /// تاريخ البداية
  @HiveField(8)
  final DateTime startDate;

  /// تاريخ الانتهاء / التسليم
  @HiveField(9)
  final DateTime dueDate;

  /// الدرجة الكاملة
  @HiveField(10)
  final double totalMarks;

  /// حالة الواجب
  @HiveField(11)
  final String status;

  /// المرفقات (روابط أو مسارات)
  @HiveField(12)
  final List<String> attachments;

  /// تاريخ الإنشاء
  @HiveField(13)
  final DateTime createdAt;

  /// تاريخ آخر تحديث
  @HiveField(14)
  final DateTime updatedAt;

  /// TTL للكاش
  @HiveField(15)
  final DateTime? cacheExpiresAt;

  /// Constructor
  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.materialId,
    this.materialName,
    required this.teacherId,
    this.teacherName,
    required this.grade,
    required this.startDate,
    required this.dueDate,
    this.totalMarks = 100,
    this.status = 'published',
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.cacheExpiresAt,
  });

  /// نسخة معدلة
  AssignmentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? materialId,
    String? materialName,
    String? teacherId,
    String? teacherName,
    String? grade,
    DateTime? startDate,
    DateTime? dueDate,
    double? totalMarks,
    String? status,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cacheExpiresAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      grade: grade ?? this.grade,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      totalMarks: totalMarks ?? this.totalMarks,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheExpiresAt: cacheExpiresAt ?? this.cacheExpiresAt,
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'material_id': materialId,
      'material_name': materialName,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'grade': grade,
      'start_date': startDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'total_marks': totalMarks,
      'status': status,
      'attachments': attachments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cache_expires_at': cacheExpiresAt?.toIso8601String(),
    };
  }

  /// إنشاء من Map
  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      materialId: map['material_id'] ?? '',
      materialName: map['material_name'],
      teacherId: map['teacher_id'] ?? '',
      teacherName: map['teacher_name'],
      grade: map['grade'] ?? '',
      startDate:
          map['start_date'] != null
              ? DateTime.parse(map['start_date'])
              : DateTime.now(),
      dueDate:
          map['due_date'] != null
              ? DateTime.parse(map['due_date'])
              : DateTime.now().add(const Duration(days: 7)),
      totalMarks: (map['total_marks'] ?? 100).toDouble(),
      status: map['status'] ?? 'published',
      attachments: List<String>.from(map['attachments'] ?? []),
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
  factory AssignmentModel.fromJson(String source) =>
      AssignmentModel.fromMap(json.decode(source));

  /// هل الواجب منتهي الصلاحية؟
  bool get isOverdue => DateTime.now().isAfter(dueDate);

  /// هل الواجب مفتوح؟
  bool get isOpen => status == 'published' && !isOverdue;

  /// الوقت المتبقي للتسليم
  Duration get remainingTime => dueDate.difference(DateTime.now());

  /// هل الكاش منتهي؟
  bool get isCacheExpired {
    if (cacheExpiresAt == null) return true;
    return DateTime.now().isAfter(cacheExpiresAt!);
  }

  @override
  String toString() {
    return 'AssignmentModel(id: $id, title: $title, dueDate: $dueDate)';
  }
}

/// نموذج تسليم الواجب / Assignment Submission Model
@HiveType(typeId: 5)
class AssignmentSubmissionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String assignmentId;

  @HiveField(2)
  final String studentId;

  @HiveField(3)
  final String? studentName;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final List<String> attachments;

  @HiveField(6)
  final DateTime submittedAt;

  @HiveField(7)
  final double? score;

  @HiveField(8)
  final String? feedback;

  @HiveField(9)
  final String status;

  @HiveField(10)
  final DateTime? gradedAt;

  AssignmentSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.studentName,
    required this.content,
    this.attachments = const [],
    required this.submittedAt,
    this.score,
    this.feedback,
    this.status = 'submitted',
    this.gradedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'student_name': studentName,
      'content': content,
      'attachments': attachments,
      'submitted_at': submittedAt.toIso8601String(),
      'score': score,
      'feedback': feedback,
      'status': status,
      'graded_at': gradedAt?.toIso8601String(),
    };
  }

  factory AssignmentSubmissionModel.fromMap(Map<String, dynamic> map) {
    return AssignmentSubmissionModel(
      id: map['id'] ?? '',
      assignmentId: map['assignment_id'] ?? '',
      studentId: map['student_id'] ?? '',
      studentName: map['student_name'],
      content: map['content'] ?? '',
      attachments: List<String>.from(map['attachments'] ?? []),
      submittedAt:
          map['submitted_at'] != null
              ? DateTime.parse(map['submitted_at'])
              : DateTime.now(),
      score: map['score']?.toDouble(),
      feedback: map['feedback'],
      status: map['status'] ?? 'submitted',
      gradedAt:
          map['graded_at'] != null ? DateTime.parse(map['graded_at']) : null,
    );
  }

  bool get isGraded => status == 'graded' && score != null;
}
