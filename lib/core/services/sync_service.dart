// ========================================
// sync_service.dart - خدمة المزامنة
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import 'network_service.dart';
import 'prefs_service.dart';
import 'sqlite_service.dart';
import 'hive_service.dart';

import '../../data/models/student_model.dart';
import '../../data/models/teacher_model.dart';
import '../../data/models/material_model.dart';
import '../../data/models/assignment_model.dart';

/// خدمة مزامنة البيانات بين التخزين المحلي والسيرفر
class SyncService {
  final NetworkService _network = NetworkService();
  final PrefsService _prefs = PrefsService();
  final SqliteService _sqlite = SqliteService();
  final HiveService _hive = HiveService();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // ===== المزامنة الكاملة / Full Sync =====

  /// تنفيذ عملية مزامنة كاملة مع محاولات إعادة المحاولة
  Future<bool> syncAll({int maxRetries = 3}) async {
    if (_isSyncing) return false;
    _isSyncing = true;

    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        debugPrint('🔄 Sync attempt ${retryCount + 1}...');

        // 1. رفع التغييرات المحلية
        await _uploadLocalChanges();

        // 2. تحميل التحديثات من السيرفر
        await _downloadServerUpdates();

        // 3. تحديث وقت آخر مزامنة
        await _prefs.setLastSyncDate(DateTime.now());

        debugPrint('✅ Full Sync Completed');
        success = true;
      } catch (e) {
        retryCount++;
        debugPrint('❌ Sync Attempt $retryCount Failed: $e');
        if (retryCount < maxRetries) {
          // انتظار بتزايد أسي (Exponential Backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      }
    }

    _isSyncing = false;
    return success;
  }

  // ===== رفع البيانات / Upload =====

  /// اكتشاف ورفع التغييرات المحلية غير المتزامنة
  Future<void> _uploadLocalChanges() async {
    // هذه مجرد مسودة - في الواقع سنحتاج لتتبع ما تم تعديله
    // حالياً سنقوم برفع كل البيانات المحلية للتأكد من وجودها على السيرفر

    List<Map<String, dynamic>> syncPayload = [];

    // إضافة الطلاب
    final students = await _hive.getStudents();
    for (var s in students) {
      syncPayload.add({
        'table': 'students',
        'action': 'save',
        'payload': s.toMap(),
      });
    }

    // إضافة المعلمين
    final teachers = await _hive.getTeachers();
    for (var t in teachers) {
      syncPayload.add({
        'table': 'teachers',
        'action': 'save',
        'payload': t.toMap(),
      });
    }

    if (syncPayload.isNotEmpty) {
      final response = await _network.post(
        ApiEndpoints.sync,
        body: {'data': syncPayload},
      );

      if (!response.success) {
        throw Exception('Server rejected sync upload: ${response.message}');
      }
    }
  }

  // ===== تحميل البيانات / Download =====

  /// تحميل التحديثات الجديدة من السيرفر
  Future<void> _downloadServerUpdates() async {
    final lastSync = _prefs.lastSyncDate;

    final response = await _network.get(
      '${ApiEndpoints.sync}?last_sync=${lastSync.toIso8601String()}',
    );

    if (response.success && response.data != null) {
      final data = response.data!;

      // تحديث الطلاب
      if (data['students'] != null) {
        for (var sMap in data['students']) {
          await _hive.saveStudent(StudentModel.fromMap(sMap));
        }
      }

      // تحديث المعلمين
      if (data['teachers'] != null) {
        for (var tMap in data['teachers']) {
          await _hive.saveTeacher(TeacherModel.fromMap(tMap));
        }
      }

      // تحديث المواد
      if (data['materials'] != null) {
        for (var mMap in data['materials']) {
          await _hive.saveMaterial(MaterialModel.fromMap(mMap));
        }
      }

      // تحديث الواجبات
      if (data['assignments'] != null) {
        for (var aMap in data['assignments']) {
          await _hive.saveAssignment(AssignmentModel.fromMap(aMap));
        }
      }
    }
  }

  // ===== مزامنة الإحصائيات / Stats Sync =====

  /// رفع سجلات تسجيل الدخول إلى السيرفر
  Future<void> syncLoginLogs() async {
    final logs = await _sqlite.getLoginLogs();
    if (logs.isEmpty) return;

    // TODO: إضافة endpoint على السيرفر لاستقبال السجلات
    // ثم مسحها محلياً أو وضع علامة "تمت المزامنة"
  }
}
