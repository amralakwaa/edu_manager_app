// ========================================
// user_model.dart - نموذج المستخدم
// نظام إدارة التعليم / Education Management System
// ========================================
//
// النموذج الأساسي للمستخدم
// يُخزن في SharedPreferences للوصول السريع

import 'dart:convert';

/// أنواع الصلاحيات / User Roles
enum UserRole { admin, teacher, student }

/// تحويل النص إلى UserRole
extension UserRoleExtension on UserRole {
  /// الحصول على اسم الصلاحية بالعربية
  String get nameAr {
    switch (this) {
      case UserRole.admin:
        return 'مدير النظام';
      case UserRole.teacher:
        return 'معلم';
      case UserRole.student:
        return 'طالب';
    }
  }

  /// الحصول على اسم الصلاحية بالإنجليزية
  String get nameEn {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
    }
  }

  /// تحويل إلى نص للتخزين
  String get value => toString().split('.').last;
}

/// تحويل النص إلى UserRole
UserRole userRoleFromString(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'teacher':
      return UserRole.teacher;
    case 'student':
      return UserRole.student;
    default:
      return UserRole.student;
  }
}

/// نموذج المستخدم / User Model
/// يُستخدم لتخزين بيانات المستخدم الحالي
class UserModel {
  /// معرف المستخدم الفريد
  final String id;

  /// الاسم الكامل
  final String name;

  /// البريد الإلكتروني
  final String email;

  /// كلمة المرور المشفرة (للتخزين المحلي فقط)
  final String? passwordHash;

  /// الصلاحية (admin, teacher, student)
  final UserRole role;

  /// معرف الجهاز الفريد
  final String deviceId;

  /// رمز التوثيق / JWT Token
  final String? token;

  /// تاريخ آخر تسجيل دخول
  final DateTime? lastLogin;

  /// الصورة الشخصية (URL أو مسار محلي)
  final String? avatarUrl;

  /// رقم الهاتف
  final String? phone;

  /// هل الحساب مفعل؟
  final bool isActive;

  /// تاريخ إنشاء الحساب
  final DateTime createdAt;

  /// تاريخ آخر تحديث
  final DateTime updatedAt;

  /// Constructor
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.passwordHash,
    required this.role,
    required this.deviceId,
    this.token,
    this.lastLogin,
    this.avatarUrl,
    this.phone,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// إنشاء نسخة معدلة / Copy with
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    UserRole? role,
    String? deviceId,
    String? token,
    DateTime? lastLogin,
    String? avatarUrl,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      deviceId: deviceId ?? this.deviceId,
      token: token ?? this.token,
      lastLogin: lastLogin ?? this.lastLogin,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحويل إلى Map للتخزين
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'role': role.value,
      'device_id': deviceId,
      'token': token,
      'last_login': lastLogin?.toIso8601String(),
      'avatar_url': avatarUrl,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// إنشاء من Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      passwordHash: map['password_hash'],
      role: userRoleFromString(map['role'] ?? 'student'),
      deviceId: map['device_id'] ?? '',
      token: map['token'],
      lastLogin:
          map['last_login'] != null ? DateTime.parse(map['last_login']) : null,
      avatarUrl: map['avatar_url'],
      phone: map['phone'],
      isActive: map['is_active'] ?? true,
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

  /// تحويل إلى JSON String
  String toJson() => json.encode(toMap());

  /// إنشاء من JSON String
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  /// مستخدم فارغ للتهيئة
  factory UserModel.empty() {
    return UserModel(
      id: '',
      name: '',
      email: '',
      role: UserRole.student,
      deviceId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// هل المستخدم مسجل الدخول؟
  bool get isLoggedIn => token != null && token!.isNotEmpty;

  /// هل هو Admin؟
  bool get isAdmin => role == UserRole.admin;

  /// هل هو معلم؟
  bool get isTeacher => role == UserRole.teacher;

  /// هل هو طالب؟
  bool get isStudent => role == UserRole.student;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: ${role.nameEn})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
