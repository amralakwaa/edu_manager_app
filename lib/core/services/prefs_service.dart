// ========================================
// prefs_service.dart - خدمة SharedPreferences
// نظام إدارة التعليم / Education Management System
// ========================================
//
// تخزين بيانات المستخدم والإعدادات
// Device ID + User Data + Settings

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/user_model.dart';

/// مفاتيح التخزين / Storage Keys
class PrefsKeys {
  static const String deviceId = 'device_id';
  static const String currentUser = 'current_user';
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String isLoggedIn = 'is_logged_in';
  static const String rememberMe = 'remember_me';
  static const String lastLoginEmail = 'last_login_email';
  static const String isDarkMode = 'is_dark_mode';
  static const String language = 'language';
  static const String serverUrl = 'server_url';
  static const String lastSyncTime = 'last_sync_time';
  static const String hotspotSSID = 'hotspot_ssid';
  static const String hotspotPassword = 'hotspot_password';
  static const String onboardingComplete = 'onboarding_complete';
}

/// خدمة SharedPreferences
class PrefsService {
  static final PrefsService _instance = PrefsService._internal();
  factory PrefsService() => _instance;
  PrefsService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// تهيئة SharedPreferences
  Future<void> init() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();

    // إنشاء Device ID إذا لم يكن موجوداً
    await _ensureDeviceId();

    _isInitialized = true;
    print('✅ SharedPreferences initialized successfully');
  }

  /// التأكد من وجود Device ID
  Future<void> _ensureDeviceId() async {
    final existingId = _prefs?.getString(PrefsKeys.deviceId);
    if (existingId == null || existingId.isEmpty) {
      final newId = const Uuid().v4();
      await _prefs?.setString(PrefsKeys.deviceId, newId);
      print('✅ New Device ID generated: $newId');
    }
  }

  /// الحصول على SharedPreferences
  SharedPreferences get prefs {
    if (!_isInitialized || _prefs == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ===== Device ID =====

  /// الحصول على Device ID
  String get deviceId => prefs.getString(PrefsKeys.deviceId) ?? '';

  // ===== المستخدم الحالي / Current User =====

  /// حفظ بيانات المستخدم الحالي
  Future<void> saveCurrentUser(UserModel user) async {
    await prefs.setString(PrefsKeys.currentUser, user.toJson());
    await prefs.setBool(PrefsKeys.isLoggedIn, true);
    if (user.token != null) {
      await prefs.setString(PrefsKeys.authToken, user.token!);
    }
  }

  /// الحصول على المستخدم الحالي
  UserModel? getCurrentUser() {
    final userJson = prefs.getString(PrefsKeys.currentUser);
    if (userJson == null || userJson.isEmpty) return null;

    try {
      return UserModel.fromJson(userJson);
    } catch (e) {
      print('❌ Error parsing user: $e');
      return null;
    }
  }

  /// تحديث توكن المستخدم
  Future<void> updateUserToken(String token) async {
    await prefs.setString(PrefsKeys.authToken, token);

    final user = getCurrentUser();
    if (user != null) {
      await saveCurrentUser(user.copyWith(token: token));
    }
  }

  /// هل المستخدم مسجل الدخول؟
  bool get isLoggedIn => prefs.getBool(PrefsKeys.isLoggedIn) ?? false;

  /// الحصول على التوكن
  String? get authToken => prefs.getString(PrefsKeys.authToken);

  /// حذف بيانات المستخدم (تسجيل الخروج)
  Future<void> clearCurrentUser() async {
    await prefs.remove(PrefsKeys.currentUser);
    await prefs.remove(PrefsKeys.authToken);
    await prefs.remove(PrefsKeys.refreshToken);
    await prefs.setBool(PrefsKeys.isLoggedIn, false);
  }

  // ===== Remember Me =====

  /// حفظ خيار "تذكرني"
  Future<void> setRememberMe(bool value, {String? email}) async {
    await prefs.setBool(PrefsKeys.rememberMe, value);
    if (value && email != null) {
      await prefs.setString(PrefsKeys.lastLoginEmail, email);
    } else if (!value) {
      await prefs.remove(PrefsKeys.lastLoginEmail);
    }
  }

  /// هل خيار "تذكرني" مفعل؟
  bool get rememberMe => prefs.getBool(PrefsKeys.rememberMe) ?? false;

  /// الحصول على آخر بريد إلكتروني
  String? get lastLoginEmail => prefs.getString(PrefsKeys.lastLoginEmail);

  // ===== الإعدادات / Settings =====

  /// حفظ الوضع الداكن
  Future<void> setDarkMode(bool value) async {
    await prefs.setBool(PrefsKeys.isDarkMode, value);
  }

  /// هل الوضع الداكن مفعل؟
  bool get isDarkMode => prefs.getBool(PrefsKeys.isDarkMode) ?? true;

  /// حفظ اللغة
  Future<void> setLanguage(String languageCode) async {
    await prefs.setString(PrefsKeys.language, languageCode);
  }

  /// الحصول على اللغة
  String get language => prefs.getString(PrefsKeys.language) ?? 'ar';

  // ===== إعدادات السيرفر / Server Settings =====

  /// حفظ رابط السيرفر
  Future<void> setServerUrl(String url) async {
    await prefs.setString(PrefsKeys.serverUrl, url);
  }

  /// الحصول على رابط السيرفر
  String get serverUrl =>
      prefs.getString(PrefsKeys.serverUrl) ??
      'http://localhost/edu_manager/api';

  /// الحصول على وقت آخر مزامنة
  DateTime get lastSyncDate {
    final timeStr = prefs.getString(PrefsKeys.lastSyncTime);
    if (timeStr == null) return DateTime(2000); // تاريخ افتراضي قديم
    return DateTime.tryParse(timeStr) ?? DateTime(2000);
  }

  /// حفظ وقت آخر مزامنة
  Future<void> setLastSyncDate(DateTime time) async {
    await prefs.setString(PrefsKeys.lastSyncTime, time.toIso8601String());
  }

  // ===== إعدادات Hotspot =====

  /// حفظ إعدادات Hotspot
  Future<void> setHotspotSettings({
    required String ssid,
    required String password,
  }) async {
    await prefs.setString(PrefsKeys.hotspotSSID, ssid);
    await prefs.setString(PrefsKeys.hotspotPassword, password);
  }

  /// الحصول على SSID
  String get hotspotSSID =>
      prefs.getString(PrefsKeys.hotspotSSID) ?? 'EduManager_Hotspot';

  /// الحصول على كلمة مرور Hotspot
  String get hotspotPassword =>
      prefs.getString(PrefsKeys.hotspotPassword) ?? 'EduManager123';

  // ===== Onboarding =====

  /// تحديد اكتمال Onboarding
  Future<void> setOnboardingComplete(bool value) async {
    await prefs.setBool(PrefsKeys.onboardingComplete, value);
  }

  /// هل اكتمل Onboarding؟
  bool get isOnboardingComplete =>
      prefs.getBool(PrefsKeys.onboardingComplete) ?? false;

  // ===== عمليات عامة / General Operations =====

  /// حفظ قيمة String
  Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  /// الحصول على قيمة String
  String? getString(String key) => prefs.getString(key);

  /// حفظ قيمة Bool
  Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  /// الحصول على قيمة Bool
  bool? getBool(String key) => prefs.getBool(key);

  /// حفظ قيمة Int
  Future<void> setInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  /// الحصول على قيمة Int
  int? getInt(String key) => prefs.getInt(key);

  /// حذف مفتاح
  Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  /// مسح كل البيانات
  Future<void> clearAll() async {
    final deviceIdBackup = deviceId;
    await prefs.clear();
    // إعادة Device ID بعد المسح
    await prefs.setString(PrefsKeys.deviceId, deviceIdBackup);
  }
}
