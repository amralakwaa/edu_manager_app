// ========================================
// login_screen.dart - شاشة تسجيل الدخول
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../providers/user_provider.dart';
import '../../core/utils/ui_utils.dart';

/// شاشة تسجيل الدخول الفخمة / Premium Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _rememberMe = false;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();

    final success = await userProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (success && mounted) {
      // التوجيه حسب الصلاحية
      final user = userProvider.currentUser;
      if (user != null) {
        switch (user.role.name) {
          case 'admin':
            Navigator.pushReplacementNamed(context, '/admin');
            break;
          case 'teacher':
            Navigator.pushReplacementNamed(context, '/teacher');
            break;
          case 'student':
            Navigator.pushReplacementNamed(context, '/student');
            break;
        }
      }
    } else if (mounted) {
      UIUtils.showErrorSnackBar(
        context,
        userProvider.error ?? 'فشل تسجيل الدخول',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: isWeb ? 450 : double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // الشعار والعنوان
                          _buildHeader(),
                          const SizedBox(height: 40),

                          // اختيار الصلاحية
                          _buildRoleSelector(),
                          const SizedBox(height: 24),

                          // حقل البريد الإلكتروني
                          CustomTextField(
                            controller: _emailController,
                            label: AppStrings.email,
                            hint: 'example@email.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16),

                          // حقل كلمة المرور
                          PasswordTextField(
                            controller: _passwordController,
                            label: AppStrings.password,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                            onSubmitted: (_) => _handleLogin(),
                          ),
                          const SizedBox(height: 16),

                          // تذكرني
                          _buildRememberMe(),
                          const SizedBox(height: 32),

                          // زر تسجيل الدخول
                          Consumer<UserProvider>(
                            builder: (context, provider, _) {
                              return CustomButton(
                                text: AppStrings.loginButton,
                                onPressed: _handleLogin,
                                isLoading: provider.isLoading,
                                icon: Icons.login,
                                width: double.infinity,
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // نسيت كلمة المرور
                          TextButton(
                            onPressed: () {
                              // TODO: صفحة استعادة كلمة المرور
                            },
                            child: const Text(
                              AppStrings.forgotPassword,
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // أيقونة التطبيق
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Hero(
            tag: 'app_logo',
            child: Icon(Icons.school, size: 48, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        // اسم التطبيق
        const Text(
          AppStrings.appName,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.login,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildRoleButton(
            'admin',
            AppStrings.admin,
            Icons.admin_panel_settings,
          ),
          _buildRoleButton('teacher', AppStrings.teacher, Icons.person),
          _buildRoleButton('student', AppStrings.student, Icons.school),
        ],
      ),
    );
  }

  Widget _buildRoleButton(String role, String label, IconData icon) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
          // تعبئة بريد تجريبي
          if (role == 'admin') {
            _emailController.text = 'admin@edumanager.com';
          } else if (role == 'teacher') {
            _emailController.text = 'ahmed@edumanager.com';
          } else {
            _emailController.text = 'mohammed@student.com';
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _rememberMe ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        _rememberMe
                            ? AppColors.accent
                            : AppColors.textSecondary,
                  ),
                ),
                child:
                    _rememberMe
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.rememberMe,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }
}
