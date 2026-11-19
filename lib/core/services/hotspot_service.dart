// ========================================
// hotspot_service.dart - خدمة نقطة الاتصال
// نظام إدارة التعليم / Education Management System
// ========================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:wifi_iot/wifi_iot.dart';

/// خدمة إدارة نقطة الاتصال والشبكة المحلية / Hotspot & Local Network Service
/// تدعم الأندرويد فقط حالياً
class HotspotService {
  // تفعيل وضع التصحيح
  final bool _debug = true;

  /// هل التطبيق يعمل على الأندرويد؟
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  // ===== إدارة نقطة الاتصال / Hotspot Management =====

  /// تشغيل نقطة الاتصال
  Future<bool> enableHotspot() async {
    if (!isAndroid) return false;

    try {
      // التحقق من الصلاحيات (يتم طلبها عادة عبر الإعدادات في الإصدارات الحديثة)
      // ملاحظة: wifi_iot 0.3.19+ لا يوفر isWriteSettingsGranted مباشرة بشكل ثابت أحياناً
      // سنحاول تشغيل الـ AP مباشرة، وإذا فشل قد يكون بسبب الصلاحيات
      return await WiFiForIoTPlugin.setWiFiAPEnabled(true);
    } catch (e) {
      if (_debug) debugPrint('Error enabling hotspot: $e');
      return false;
    }
  }

  /// إيقاف نقطة الاتصال
  Future<bool> disableHotspot() async {
    if (!isAndroid) return false;

    try {
      return await WiFiForIoTPlugin.setWiFiAPEnabled(false);
    } catch (e) {
      if (_debug) debugPrint('Error disabling hotspot: $e');
      return false;
    }
  }

  /// الحصول على حالة نقطة الاتصال
  Future<bool> isHotspotEnabled() async {
    if (!isAndroid) return false;
    return await WiFiForIoTPlugin.isWiFiAPEnabled();
  }

  // ===== معلومات الشبكة / Network Information =====

  /// الحصول على عنوان الـ IP للجهاز الحالي (الخادم)
  Future<String?> getIpAddress() async {
    try {
      if (kIsWeb) return null;

      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      if (_debug) debugPrint('Error getting IP address: $e');
    }
    return null;
  }

  // ===== الاتصال بالشبكة / Client Operations =====

  /// الاتصال بنقطة اتصال محددة
  Future<bool> connectToHotspot(String ssid, {String? password}) async {
    if (!isAndroid) return false;

    try {
      await WiFiForIoTPlugin.setEnabled(true);

      bool result = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        security: password != null ? NetworkSecurity.WPA : NetworkSecurity.NONE,
        joinOnce: true,
      );

      if (result) {
        await WiFiForIoTPlugin.forceWifiUsage(true);
      }

      return result;
    } catch (e) {
      if (_debug) debugPrint('Error connecting to hotspot: $e');
      return false;
    }
  }

  /// فصل الاتصال
  Future<void> disconnect() async {
    if (!isAndroid) return;
    await WiFiForIoTPlugin.disconnect();
    await WiFiForIoTPlugin.forceWifiUsage(false);
  }
}
