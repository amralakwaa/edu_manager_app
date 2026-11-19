// ========================================
// add_material_screen.dart - إضافة مادة جديدة
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../../data/models/material_model.dart';
import '../../../core/utils/ui_utils.dart';

class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final HiveService _hive = HiveService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedGrade = '10';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final materialId = const Uuid().v4();
      final material = MaterialModel(
        id: materialId,
        name: _titleController.text,
        code: _codeController.text,
        description: _descriptionController.text,
        grade: _selectedGrade,
        semester: 'Fall 2026', // قيمة افتراضية
        teacherId: 'ADMIN', // مؤقتاً
        teacherName: 'Admin',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _hive.put(HiveBoxes.materials, material.id, material.toMap());

      if (mounted) {
        UIUtils.showSuccessSnackBar(context, 'تمت إضافة المادة بنجاح!');
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
      appBar: AppBar(title: const Text('إضافة مادة دراسية')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('عنوان المادة', _titleController, Icons.book),
              const SizedBox(height: 20),
              _buildTextField(
                'كود المادة (مثل MAT101)',
                _codeController,
                Icons.code,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'الوصف',
                _descriptionController,
                Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildGradeDropdown(),
              const SizedBox(height: 48),
              _buildSubmitButton(),
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
    int maxLines = 1,
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
          maxLines: maxLines,
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

  Widget _buildGradeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الصف الدراسي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGrade,
              isExpanded: true,
              dropdownColor: AppColors.backgroundDark,
              style: const TextStyle(color: AppColors.textPrimary),
              items:
                  ['10', '11', '12'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('الصف $value'),
                    );
                  }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedGrade = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveMaterial,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child:
          _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                'حفظ المادة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }
}
