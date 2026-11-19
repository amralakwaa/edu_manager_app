// ========================================
// add_user_screen.dart - إضافة مستخدم جديد
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/teacher_model.dart';
import '../../../core/utils/ui_utils.dart';

class AddUserScreen extends StatefulWidget {
  final UserRole initialRole;

  const AddUserScreen({super.key, this.initialRole = UserRole.student});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final HiveService _hive = HiveService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late UserRole _selectedRole;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = const Uuid().v4();

      if (_selectedRole == UserRole.student) {
        final student = StudentModel(
          id: userId,
          userId: userId, // لمبسط هنا نفترض نفس المعرف
          name: _nameController.text,
          email: _emailController.text,
          studentNumber: 'ST-${const Uuid().v4().substring(0, 8)}',
          grade: '10',
          section: 'A',
          enrollmentDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _hive.put(HiveBoxes.students, student.id, student.toMap());
      } else {
        final teacher = TeacherModel(
          id: userId,
          userId: userId,
          name: _nameController.text,
          email: _emailController.text,
          employeeNumber: 'TCH-${const Uuid().v4().substring(0, 8)}',
          specialization: 'General',
          qualification: 'Bachelor',
          hireDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _hive.put(HiveBoxes.teachers, teacher.id, teacher.toMap());
      }

      if (mounted) {
        UIUtils.showSuccessSnackBar(context, 'تمت إضافة المستخدم بنجاح!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        UIUtils.showErrorSnackBar(context, 'خطأ في الحفظ: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مستخدم جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoleSelector(),
              const SizedBox(height: 32),
              _buildTextField('الاسم الكامل', _nameController, Icons.person),
              const SizedBox(height: 20),
              _buildTextField(
                'البريد الإلكتروني',
                _emailController,
                Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'كلمة المرور المؤقتة',
                _passwordController,
                Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 48),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildRoleTab(UserRole.student, 'طالب', Icons.school),
          _buildRoleTab(UserRole.teacher, 'معلم', Icons.person),
        ],
      ),
    );
  }

  Widget _buildRoleTab(UserRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator:
              (val) => val == null || val.isEmpty ? 'هذا الحقل مطلوب' : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.accent),
            fillColor: AppColors.cardBackground,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child:
          _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                'حفظ المستخدم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }
}
