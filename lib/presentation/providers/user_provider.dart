// ========================================
// user_provider.dart - مزود حالة المستخدم
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../core/services/prefs_service.dart';
import '../../core/services/network_service.dart';
import '../../core/services/sqlite_service.dart';
import '../../core/constants/api_endpoints.dart';

/// مزود حالة المستخدم / User State Provider
class UserProvider extends ChangeNotifier {
  final PrefsService _prefs = PrefsService();
  final NetworkService _network = NetworkService();
  final SqliteService _sqlite = SqliteService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // ===== Getters =====

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && _currentUser!.isLoggedIn;
  bool get isInitialized => _isInitialized;

  // ===== تهيئة المستخدم / Initialize User =====

  /// تهيئة المستخدم من التخزين المحلي
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _prefs.init();

      // التحقق من وجود مستخدم محفوظ
      final savedUser = _prefs.getCurrentUser();
      if (savedUser != null && savedUser.isLoggedIn) {
        _currentUser = savedUser;

        // محاولة التحقق من صلاحية التوكن
        await _verifyToken();
      }

      _isInitialized = true;
    } catch (e) {
      _error = 'فشل في تهيئة المستخدم';
      debugPrint('UserProvider initialize error: $e');
    }

    notifyListeners();
  }

  // ===== تسجيل الدخول / Login =====

  /// تسجيل الدخول
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _network.post(
        ApiEndpoints.login,
        body: {
          'email': email,
          'password': password,
          'device_id': _prefs.deviceId,
        },
      );

      if (response.success && response.data != null) {
        final userData = response.data!['user'];
        final token = response.data!['token'];

        _currentUser = UserModel.fromMap({
          ...userData,
          'token': token,
          'device_id': _prefs.deviceId,
        });

        // حفظ المستخدم
        await _prefs.saveCurrentUser(_currentUser!);
        await _prefs.setRememberMe(rememberMe, email: email);

        // تسجيل في SQLite
        await _sqlite.logLogin(
          userId: _currentUser!.id,
          userRole: _currentUser!.role.value,
          deviceId: _prefs.deviceId,
        );

        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'فشل تسجيل الدخول';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'خطأ في الاتصال';
      debugPrint('Login error: $e');
      _setLoading(false);
      return false;
    }
  }

  // ===== تسجيل الخروج / Logout =====

  /// تسجيل الخروج
  Future<void> logout() async {
    _setLoading(true);

    try {
      // إرسال طلب تسجيل الخروج للسيرفر
      await _network.post(ApiEndpoints.logout);
    } catch (e) {
      debugPrint('Logout API error: $e');
    }

    // مسح البيانات المحلية
    await _prefs.clearCurrentUser();
    _currentUser = null;

    _setLoading(false);
  }

  // ===== التحقق من التوكن / Verify Token =====

  Future<void> _verifyToken() async {
    try {
      final response = await _network.get(ApiEndpoints.verifyToken);

      if (!response.success) {
        // التوكن غير صالح - تسجيل الخروج
        await logout();
      }
    } catch (e) {
      debugPrint('Token verification error: $e');
      // لا نسجل الخروج هنا للسماح بالعمل offline
    }
  }

  // ===== تحديث المستخدم / Update User =====

  /// تحديث بيانات المستخدم
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _error = null;

    try {
      final response = await _network.put(
        ApiEndpoints.updateUser,
        body: {
          'id': _currentUser!.id,
          'name': name ?? _currentUser!.name,
          'phone': phone ?? _currentUser!.phone,
          'avatar_url': avatarUrl ?? _currentUser!.avatarUrl,
        },
      );

      if (response.success) {
        _currentUser = _currentUser!.copyWith(
          name: name ?? _currentUser!.name,
          phone: phone ?? _currentUser!.phone,
          avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
        );

        await _prefs.saveCurrentUser(_currentUser!);
        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'فشل تحديث البيانات';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'خطأ في الاتصال';
      _setLoading(false);
      return false;
    }
  }

  // ===== تغيير كلمة المرور / Change Password =====

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _error = null;

    try {
      final response = await _network.post(
        ApiEndpoints.resetPassword,
        body: {
          'user_id': _currentUser!.id,
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.success) {
        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'فشل تغيير كلمة المرور';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'خطأ في الاتصال';
      _setLoading(false);
      return false;
    }
  }

  // ===== مساعدات / Helpers =====

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
