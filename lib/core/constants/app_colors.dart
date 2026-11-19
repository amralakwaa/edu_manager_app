/// ========================================
/// app_colors.dart - ألوان التطبيق
/// نظام إدارة التعليم / Education Management System
/// ========================================
///
/// هذا الملف يحتوي على جميع ألوان التطبيق
/// تصميم فخم بألوان متناسقة واحترافية

import 'package:flutter/material.dart';

/// ألوان التطبيق الرئيسية
/// Main application colors with premium design
class AppColors {
  // منع إنشاء نسخة من الكلاس
  AppColors._();

  // ===== الألوان الأساسية / Primary Colors =====

  /// اللون الأساسي - أزرق داكن فخم
  /// Primary deep blue - premium feel
  static const Color primary = Color(0xFF1E3A5F);

  /// اللون الأساسي الفاتح
  static const Color primaryLight = Color(0xFF2E5A8F);

  /// اللون الأساسي الداكن
  static const Color primaryDark = Color(0xFF0E2A4F);

  // ===== الألوان الثانوية / Secondary Colors =====

  /// اللون الذهبي - للعناصر المميزة
  /// Golden color for premium elements
  static const Color secondary = Color(0xFFD4AF37);

  /// الذهبي الفاتح
  static const Color secondaryLight = Color(0xFFE4CF67);

  /// الذهبي الداكن
  static const Color secondaryDark = Color(0xFFB49317);

  // ===== لون التمييز / Accent Color =====

  /// لون تيل للأزرار والروابط
  /// Teal accent for buttons and links
  static const Color accent = Color(0xFF00BFA5);

  /// تيل فاتح
  static const Color accentLight = Color(0xFF5DF2D6);

  /// تيل داكن
  static const Color accentDark = Color(0xFF008E76);

  // ===== ألوان الخلفية / Background Colors =====

  /// خلفية داكنة أساسية
  static const Color backgroundDark = Color(0xFF0F1923);

  /// خلفية متوسطة
  static const Color backgroundMedium = Color(0xFF1A2836);

  /// خلفية فاتحة (للوضع الفاتح)
  static const Color backgroundLight = Color(0xFFF5F7FA);

  /// خلفية البطاقات
  static const Color cardBackground = Color(0xFF1E2D3D);

  /// خلفية شفافة للـ Glassmorphism
  static const Color glassBackground = Color(0x1AFFFFFF);

  // ===== ألوان النصوص / Text Colors =====

  /// نص أبيض رئيسي
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// نص ثانوي (رمادي فاتح)
  static const Color textSecondary = Color(0xFFB0BEC5);

  /// نص معطل
  static const Color textDisabled = Color(0xFF607D8B);

  /// نص داكن (للوضع الفاتح)
  static const Color textDark = Color(0xFF1E3A5F);

  // ===== ألوان الحالات / Status Colors =====

  /// نجاح - أخضر
  static const Color success = Color(0xFF4CAF50);

  /// تحذير - برتقالي
  static const Color warning = Color(0xFFFF9800);

  /// خطأ - أحمر
  static const Color error = Color(0xFFE53935);

  /// معلومات - أزرق
  static const Color info = Color(0xFF2196F3);

  // ===== ألوان الصلاحيات / Role Colors =====

  /// لون Admin - أحمر ذهبي
  static const Color adminColor = Color(0xFFB71C1C);

  /// لون Teacher - أزرق
  static const Color teacherColor = Color(0xFF1565C0);

  /// لون Teacher فاتح
  static const Color teacherColorLight = Color(0xFF42A5F5);

  /// لون Student - أخضر
  static const Color studentColor = Color(0xFF2E7D32);

  /// لون Student فاتح
  static const Color studentColorLight = Color(0xFF66BB6A);

  // ===== التدرجات / Gradients =====

  /// تدرج الخلفية الرئيسي
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDark, primary],
  );

  /// تدرج البطاقات
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E3D4D), Color(0xFF1E2D3D)],
  );

  /// تدرج الأزرار الرئيسية
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accent, accentLight],
  );

  /// تدرج ذهبي للعناصر المميزة
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary, secondaryDark],
  );
}
