// ========================================
// main.dart - نقطة دخول التطبيق
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/services/prefs_service.dart';

import 'presentation/providers/user_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/admin/admin_dashboard.dart';
import 'presentation/screens/teacher/teacher_dashboard.dart';
import 'presentation/screens/student/student_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إعداد System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // تهيئة Hive
  await Hive.initFlutter();

  // تهيئة SharedPreferences
  await PrefsService().init();

  runApp(const EduManagerApp());
}

/// التطبيق الرئيسي / Main Application
class EduManagerApp extends StatelessWidget {
  const EduManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            title: 'نظام إدارة التعليم',
            debugShowCheckedModeBanner: false,

            // الثيم
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,

            // اللغة
            locale: const Locale('ar', 'SA'),

            // التوجيهات
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/admin': (context) => const AdminDashboard(),
              '/teacher': (context) => const TeacherDashboard(),
              '/student': (context) => const StudentDashboard(),
            },

            // بناء الصفحة الرئيسية
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

/// شاشة البداية / Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // تهيئة UserProvider
      await context.read<UserProvider>().initialize();

      // انتظار قليلاً لعرض Splash
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted) return;

      // التوجيه حسب حالة تسجيل الدخول
      final userProvider = context.read<UserProvider>();

      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        final role = userProvider.currentUser!.role.name;
        switch (role) {
          case 'admin':
            Navigator.pushReplacementNamed(context, '/admin');
            break;
          case 'teacher':
            Navigator.pushReplacementNamed(context, '/teacher');
            break;
          case 'student':
            Navigator.pushReplacementNamed(context, '/student');
            break;
          default:
            Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      debugPrint('Splash init error: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // الشعار
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: AppColors.buttonGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // اسم التطبيق
                      const Text(
                        'نظام إدارة التعليم',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Education Management System',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // مؤشر التحميل
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accent.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
