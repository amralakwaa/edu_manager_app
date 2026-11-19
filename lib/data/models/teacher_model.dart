// ========================================
// teacher_model.dart - نموذج المعلم
// نظام إدارة التعليم / Education Management System
// ========================================
//
// نموذج بيانات المعلم مع معلوماته الأكاديمية

import 'dart:convert';
import 'package:hive/hive.dart';

part 'teacher_model.g.dart';

/// نموذج المعلم / Teacher Model
@HiveType(typeId: 2)
class TeacherModel extends HiveObject {
  /// معرف المعلم الفريد
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

  /// رقم الموظف
  @HiveField(4)
  final String employeeNumber;

  /// التخصص
  @HiveField(5)
  final String specialization;

  /// المؤهل العلمي
  @HiveField(6)
  final String qualification;

  /// سنوات الخبرة
  @HiveField(7)
  final int experienceYears;

  /// رقم الهاتف
  @HiveField(8)
  final String? phone;

  /// العنوان
  @HiveField(9)
  final String? address;

  /// الصورة الشخصية
  @HiveField(10)
  final String? avatarUrl;

  /// المواد التي يدرسها (قائمة معرفات)
  @HiveField(11)
  final List<String> teachingMaterials;

  /// الصفوف / المراحل المسؤول عنها
  @HiveField(12)
  final List<String> assignedGrades;

  /// حالة المعلم
  @HiveField(13)
  final String status;

  /// تاريخ التعيين
  @HiveField(14)
  final DateTime hireDate;

  /// تاريخ آخر تحديث
  @HiveField(15)
  final DateTime updatedAt;

  /// Constructor
  TeacherModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.employeeNumber,
    required this.specialization,
    required this.qualification,
    this.experienceYears = 0,
    this.phone,
    this.address,
    this.avatarUrl,
    this.teachingMaterials = const [],
    this.assignedGrades = const [],
    this.status = 'active',
    required this.hireDate,
    required this.updatedAt,
  });

  /// نسخة معدلة
  TeacherModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? employeeNumber,
    String? specialization,
    String? qualification,
    int? experienceYears,
    String? phone,
    String? address,
    String? avatarUrl,
    List<String>? teachingMaterials,
    List<String>? assignedGrades,
    String? status,
    DateTime? hireDate,
    DateTime? updatedAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      experienceYears: experienceYears ?? this.experienceYears,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      teachingMaterials: teachingMaterials ?? this.teachingMaterials,
      assignedGrades: assignedGrades ?? this.assignedGrades,
      status: status ?? this.status,
      hireDate: hireDate ?? this.hireDate,
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
      'employee_number': employeeNumber,
      'specialization': specialization,
      'qualification': qualification,
      'experience_years': experienceYears,
      'phone': phone,
      'address': address,
      'avatar_url': avatarUrl,
      'teaching_materials': teachingMaterials,
      'assigned_grades': assignedGrades,
      'status': status,
      'hire_date': hireDate.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// إنشاء من Map
  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      employeeNumber: map['employee_number'] ?? '',
      specialization: map['specialization'] ?? '',
      qualification: map['qualification'] ?? '',
      experienceYears: map['experience_years'] ?? 0,
      phone: map['phone'],
      address: map['address'],
      avatarUrl: map['avatar_url'],
      teachingMaterials: List<String>.from(map['teaching_materials'] ?? []),
      assignedGrades: List<String>.from(map['assigned_grades'] ?? []),
      status: map['status'] ?? 'active',
      hireDate:
          map['hire_date'] != null
              ? DateTime.parse(map['hire_date'])
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
  factory TeacherModel.fromJson(String source) =>
      TeacherModel.fromMap(json.decode(source));

  /// معلم فارغ
  factory TeacherModel.empty() {
    return TeacherModel(
      id: '',
      userId: '',
      name: '',
      email: '',
      employeeNumber: '',
      specialization: '',
      qualification: '',
      hireDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// هل المعلم نشط؟
  bool get isActive => status == 'active';

  /// عدد المواد
  int get materialsCount => teachingMaterials.length;

  /// عدد الصفوف
  int get gradesCount => assignedGrades.length;

  @override
  String toString() {
    return 'TeacherModel(id: $id, name: $name, specialization: $specialization)';
  }
}
