// ========================================
// grades_screen.dart - إدخال الدرجات
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/grade_model.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/sqlite_service.dart';
import '../../providers/user_provider.dart';

class GradesScreen extends StatefulWidget {
  final String materialId;
  final String materialName;

  const GradesScreen({
    super.key,
    required this.materialId,
    required this.materialName,
  });

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  List<StudentModel> _students = [];
  bool _isLoading = true;

  final Map<String, TextEditingController> _gradeControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final hiveService = HiveService();
    final allStudents = await hiveService.getStudents();

    setState(() {
      _students = allStudents;
      for (var student in _students) {
        _gradeControllers[student.id] = TextEditingController();
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    for (var controller in _gradeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدخال الدرجات'),
        backgroundColor: AppColors.warning,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildPreamble(),
                  Expanded(
                    child:
                        _students.isEmpty
                            ? const Center(child: Text('لا يوجد طلاب مسجلين'))
                            : _buildGradesList(),
                  ),
                  _buildSaveButton(),
                ],
              ),
    );
  }

  Widget _buildPreamble() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.warning.withOpacity(0.05),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.materialName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'نوع الاختبار: نصفي (الفصل الأول)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_note, color: AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildGradesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  student.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _gradeControllers[student.id],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.warning),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '/ 100',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _saveGrades,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warning,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'حفظ الدرجات',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _saveGrades() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final sqliteService = SqliteService();
    final teacherId = userProvider.currentUser?.id ?? 'unknown';

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      for (var student in _students) {
        final scoreText = _gradeControllers[student.id]?.text ?? '0';
        final score = double.tryParse(scoreText) ?? 0.0;

        final grade = GradeModel(
          id: const Uuid().v4(),
          studentId: student.id,
          studentName: student.name,
          materialId: widget.materialId,
          materialName: widget.materialName,
          teacherId: teacherId,
          gradeType: 'midterm', // نصفي افتراضياً
          title: 'اختبار نصفي - الفصل الأول',
          score: score,
          totalMarks: 100,
          semester: 'الفصل الأول',
          academicYear: '2024-2025',
          gradedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await sqliteService.insertGrade(grade);
      }

      if (mounted) {
        Navigator.pop(context); // Close loading
        UIUtils.showSuccessSnackBar(context, 'تم حفظ الدرجات بنجاح');
        Navigator.pop(context); // Go back
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context); // Close loading
        UIUtils.showErrorSnackBar(context, 'خطأ في الحفظ: $e');
      }
    }
  }
}
