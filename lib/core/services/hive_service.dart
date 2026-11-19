// ========================================
// hive_service.dart - خدمة Hive
// نظام إدارة التعليم / Education Management System
// ========================================
//
// إدارة التخزين المؤقت باستخدام Hive
// تخزين الواجبات، المواد، الرسائل مع دعم TTL

import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/student_model.dart';
import '../../data/models/teacher_model.dart';
import '../../data/models/material_model.dart';
import '../../data/models/assignment_model.dart';

/// أسماء الـ Boxes
class HiveBoxes {
  static const String students = 'students';
  static const String teachers = 'teachers';
  static const String materials = 'materials';
  static const String assignments = 'assignments';
  static const String submissions = 'submissions';
  static const String grades = 'grades';
  static const String attendance = 'attendance';
  static const String cache = 'cache';
  static const String messages = 'messages';
}

/// خدمة Hive للتخزين المؤقت
class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  bool _isInitialized = false;

  /// تهيئة Hive
  /// يجب استدعاؤها في main.dart قبل runApp
  Future<void> init() async {
    if (_isInitialized) return;

    // تهيئة Hive Flutter
    await Hive.initFlutter();

    // تسجيل الـ Adapters
    // ملاحظة: سيتم توليدها تلقائياً بعد تشغيل build_runner
    _registerAdapters();

    // فتح الـ Boxes
    await _openBoxes();

    _isInitialized = true;
    print('✅ Hive initialized successfully');
  }

  /// تسجيل الـ Adapters
  void _registerAdapters() {
    // سيتم إضافة الـ adapters بعد تشغيل:
    // flutter pub run build_runner build

    // مؤقتاً: لن نسجل adapters حتى يتم التوليد
    // if (!Hive.isAdapterRegistered(1)) {
    //   Hive.registerAdapter(StudentModelAdapter());
    // }
  }

  /// فتح جميع الـ Boxes
  Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox(HiveBoxes.students),
      Hive.openBox(HiveBoxes.teachers),
      Hive.openBox(HiveBoxes.materials),
      Hive.openBox(HiveBoxes.assignments),
      Hive.openBox(HiveBoxes.submissions),
      Hive.openBox(HiveBoxes.grades),
      Hive.openBox(HiveBoxes.attendance),
      Hive.openBox(HiveBoxes.cache),
      Hive.openBox(HiveBoxes.messages),
    ]);
  }

  // ===== عمليات عامة / Generic Operations =====

  /// حفظ عنصر في Box
  Future<void> put<T>(String boxName, String key, T value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  /// الحصول على عنصر من Box
  T? get<T>(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key) as T?;
  }

  /// حذف عنصر من Box
  Future<void> delete(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  /// الحصول على كل العناصر في Box
  List<T> getAll<T>(String boxName) {
    final box = Hive.box(boxName);
    return box.values.cast<T>().toList();
  }

  /// مسح كل عناصر Box
  Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  // ===== عمليات مع TTL / TTL Operations =====

  /// حفظ عنصر مع وقت انتهاء صلاحية
  Future<void> putWithTTL<T>(
    String boxName,
    String key,
    T value,
    Duration ttl,
  ) async {
    final cacheBox = Hive.box(HiveBoxes.cache);
    final expiresAt = DateTime.now().add(ttl).toIso8601String();

    await put(boxName, key, value);
    await cacheBox.put('ttl_$boxName\_$key', expiresAt);
  }

  /// الحصول على عنصر مع فحص TTL
  T? getWithTTL<T>(String boxName, String key) {
    final cacheBox = Hive.box(HiveBoxes.cache);
    final expiresAtStr = cacheBox.get('ttl_$boxName\_$key');

    if (expiresAtStr != null) {
      final expiresAt = DateTime.parse(expiresAtStr);
      if (DateTime.now().isAfter(expiresAt)) {
        // انتهت الصلاحية - حذف
        delete(boxName, key);
        cacheBox.delete('ttl_$boxName\_$key');
        return null;
      }
    }

    return get<T>(boxName, key);
  }

  /// تنظيف العناصر منتهية الصلاحية
  Future<void> cleanExpiredItems() async {
    final cacheBox = Hive.box(HiveBoxes.cache);
    final keys = cacheBox.keys.where((k) => k.toString().startsWith('ttl_'));

    for (final key in keys) {
      final expiresAtStr = cacheBox.get(key);
      if (expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        if (DateTime.now().isAfter(expiresAt)) {
          // استخراج اسم الـ box والمفتاح
          final parts = key.toString().replaceFirst('ttl_', '').split('_');
          if (parts.length >= 2) {
            final boxName = parts[0];
            final itemKey = parts.sublist(1).join('_');
            await delete(boxName, itemKey);
          }
          await cacheBox.delete(key);
        }
      }
    }
  }

  // ===== عمليات النماذج / Model Operations =====

  /// الحصول على كل الطلاب
  Future<List<StudentModel>> getStudents() async {
    return getAll<StudentModel>(HiveBoxes.students);
  }

  /// حفظ طالب
  Future<void> saveStudent(StudentModel student) async {
    await put(HiveBoxes.students, student.id, student);
  }

  /// الحصول على كل المعلمين
  Future<List<TeacherModel>> getTeachers() async {
    return getAll<TeacherModel>(HiveBoxes.teachers);
  }

  /// حفظ معلم
  Future<void> saveTeacher(TeacherModel teacher) async {
    await put(HiveBoxes.teachers, teacher.id, teacher);
  }

  /// حفظ مادة
  Future<void> saveMaterial(MaterialModel material) async {
    await put(HiveBoxes.materials, material.id, material);
  }

  /// حفظ واجب
  Future<void> saveAssignment(AssignmentModel assignment) async {
    await put(HiveBoxes.assignments, assignment.id, assignment);
  }

  // ===== عمليات محددة / Specific Operations =====

  /// حفظ قائمة المواد مع كاش
  Future<void> cacheMaterials(List<Map<String, dynamic>> materials) async {
    final box = Hive.box(HiveBoxes.materials);
    await box.clear();
    for (final material in materials) {
      await box.put(material['id'], material);
    }
  }

  /// حفظ قائمة الواجبات مع كاش
  Future<void> cacheAssignments(List<Map<String, dynamic>> assignments) async {
    final box = Hive.box(HiveBoxes.assignments);
    await box.clear();
    for (final assignment in assignments) {
      await box.put(assignment['id'], assignment);
    }
  }

  /// الحصول على المواد المخزنة
  List<Map<String, dynamic>> getCachedMaterials() {
    final box = Hive.box(HiveBoxes.materials);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// الحصول على الواجبات المخزنة
  List<Map<String, dynamic>> getCachedAssignments() {
    final box = Hive.box(HiveBoxes.assignments);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ===== إدارة الرسائل / Messages Management =====

  /// حفظ رسالة
  Future<void> saveMessage(String id, Map<String, dynamic> message) async {
    final box = Hive.box(HiveBoxes.messages);
    await box.put(id, message);
  }

  /// الحصول على كل الرسائل
  List<Map<String, dynamic>> getMessages() {
    final box = Hive.box(HiveBoxes.messages);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// حذف رسالة
  Future<void> deleteMessage(String id) async {
    final box = Hive.box(HiveBoxes.messages);
    await box.delete(id);
  }

  // ===== إغلاق Hive =====

  /// إغلاق جميع الـ Boxes
  Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }

  /// مسح كل البيانات
  Future<void> clearAll() async {
    await Future.wait([
      clearBox(HiveBoxes.students),
      clearBox(HiveBoxes.teachers),
      clearBox(HiveBoxes.materials),
      clearBox(HiveBoxes.assignments),
      clearBox(HiveBoxes.submissions),
      clearBox(HiveBoxes.grades),
      clearBox(HiveBoxes.attendance),
      clearBox(HiveBoxes.cache),
      clearBox(HiveBoxes.messages),
    ]);
  }
}
