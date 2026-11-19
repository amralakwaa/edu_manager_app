// ========================================
// student_model.dart - نموذج الطالب
// نظام إدارة التعليم / Education Management System
// ========================================
//
// نموذج بيانات الطالب مع معلوماته الأكاديمية

import 'dart:convert';
import 'package:hive/hive.dart';

part 'student_model.g.dart';

/// حالة الطالب / Student Status
enum StudentStatus {
  active, // نشط
  inactive, // غير نشط
  graduated, // متخرج
  suspended, // موقوف
}

/// نموذج الطالب / Student Model
@HiveType(typeId: 1)
class StudentModel extends HiveObject {
  /// معرف الطالب الفريد
  @HiveField(0)
  final String id;

  /// معرف المستخدم المرتبط
  @HiveField(1)
  final String userId;

  /// الاسم الكامل
  @HiveField(2)
  final String name;

  /// البريد الإلكتروني
  @HiveField(3)
  final String email;

  /// رقم الطالب الجامعي
  @HiveField(4)
  final String studentNumber;

  /// المرحلة / الصف
  @HiveField(5)
  final String grade;

  /// الفصل / الشعبة
  @HiveField(6)
  final String section;

  /// تاريخ الميلاد
  @HiveField(7)
  final DateTime? dateOfBirth;

  /// الجنس
  @HiveField(8)
  final String? gender;

  /// رقم الهاتف
  @HiveField(9)
  final String? phone;

  /// اسم ولي الأمر
  @HiveField(10)
  final String? guardianName;

  /// هاتف ولي الأمر
  @HiveField(11)
  final String? guardianPhone;

  /// العنوان
  @HiveField(12)
  final String? address;

  /// الصورة الشخصية
  @HiveField(13)
  final String? avatarUrl;

  /// المعدل التراكمي
  @HiveField(14)
  final double gpa;

  /// حالة الطالب
  @HiveField(15)
  final String status;

  /// المواد المسجلة (قائمة معرفات)
  @HiveField(16)
  final List<String> enrolledMaterials;

  /// تاريخ التسجيل
  @HiveField(17)
  final DateTime enrollmentDate;

  /// تاريخ آخر تحديث
  @HiveField(18)
  final DateTime updatedAt;

  /// Constructor
  StudentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.studentNumber,
    required this.grade,
    required this.section,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.guardianName,
    this.guardianPhone,
    this.address,
    this.avatarUrl,
    this.gpa = 0.0,
    this.status = 'active',
    this.enrolledMaterials = const [],
    required this.enrollmentDate,
    required this.updatedAt,
  });

  /// نسخة معدلة
  StudentModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? studentNumber,
    String? grade,
    String? section,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? guardianName,
    String? guardianPhone,
    String? address,
    String? avatarUrl,
    double? gpa,
    String? status,
    List<String>? enrolledMaterials,
    DateTime? enrollmentDate,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      studentNumber: studentNumber ?? this.studentNumber,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gpa: gpa ?? this.gpa,
      status: status ?? this.status,
      enrolledMaterials: enrolledMaterials ?? this.enrolledMaterials,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'student_number': studentNumber,
      'grade': grade,
      'section': section,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'phone': phone,
      'guardian_name': guardianName,
      'guardian_phone': guardianPhone,
      'address': address,
      'avatar_url': avatarUrl,
      'gpa': gpa,
      'status': status,
      'enrolled_materials': enrolledMaterials,
      'enrollment_date': enrollmentDate.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// إنشاء من Map
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      studentNumber: map['student_number'] ?? '',
      grade: map['grade'] ?? '',
      section: map['section'] ?? '',
      dateOfBirth:
          map['date_of_birth'] != null
              ? DateTime.parse(map['date_of_birth'])
              : null,
      gender: map['gender'],
      phone: map['phone'],
      guardianName: map['guardian_name'],
      guardianPhone: map['guardian_phone'],
      address: map['address'],
      avatarUrl: map['avatar_url'],
      gpa: (map['gpa'] ?? 0).toDouble(),
      status: map['status'] ?? 'active',
      enrolledMaterials: List<String>.from(map['enrolled_materials'] ?? []),
      enrollmentDate:
          map['enrollment_date'] != null
              ? DateTime.parse(map['enrollment_date'])
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
  factory StudentModel.fromJson(String source) =>
      StudentModel.fromMap(json.decode(source));

  /// طالب فارغ
  factory StudentModel.empty() {
    return StudentModel(
      id: '',
      userId: '',
      name: '',
      email: '',
      studentNumber: '',
      grade: '',
      section: '',
      enrollmentDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// هل الطالب نشط؟
  bool get isActive => status == 'active';

  /// عدد المواد المسجلة
  int get materialsCount => enrolledMaterials.length;

  @override
  String toString() {
    return 'StudentModel(id: $id, name: $name, studentNumber: $studentNumber)';
  }
}
