// ========================================
// assignment_submission_screen.dart - تسليم الواجب
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/assignment_model.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/utils/ui_utils.dart';
import '../../providers/user_provider.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  final AssignmentModel assignment;

  const AssignmentSubmissionScreen({super.key, required this.assignment});

  @override
  State<AssignmentSubmissionScreen> createState() =>
      _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState
    extends State<AssignmentSubmissionScreen> {
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسليم الواجب'),
        backgroundColor: AppColors.studentColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAssignmentInfo(),
            const SizedBox(height: 24),
            const Text(
              'محتوى التسليم',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSubmissionField(),
            const SizedBox(height: 24),
            _buildFileUploadSection(),
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.studentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.studentColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, color: AppColors.studentColor),
              const SizedBox(width: 12),
              Text(
                widget.assignment.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.assignment.description,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                Icons.event,
                'الموعد',
                widget.assignment.dueDate.toString().split(' ').first,
              ),
              _buildInfoItem(
                Icons.grade,
                'الدرجة',
                '${widget.assignment.totalMarks}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmissionField() {
    return TextField(
      controller: _contentController,
      maxLines: 8,
      decoration: InputDecoration(
        hintText: 'اكتب إجابتك هنا...',
        fillColor: AppColors.cardBackground,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المرفقات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.1),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'اضغط لرفع ملفات أو صور',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.studentColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child:
          _isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                'إرسال الواجب',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }

  Future<void> _submit() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة محتوى للواجب أولاً')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentId = userProvider.currentUser?.id ?? 'unknown';

    setState(() => _isSubmitting = true);

    try {
      final submission = AssignmentSubmissionModel(
        id: const Uuid().v4(),
        assignmentId: widget.assignment.id,
        studentId: studentId,
        content: _contentController.text,
        submittedAt: DateTime.now(),
        status: 'pending',
        attachments: [], // مؤقتاً فارغ
      );

      final hiveService = HiveService();
      await hiveService.put(
        HiveBoxes.submissions,
        submission.id,
        submission.toMap(),
      );

      if (mounted) {
        UIUtils.showSuccessSnackBar(
          context,
          'تم حفظ الواجب محلياً بنجاح! سيتم رفعه عند توفر الاتصال.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        UIUtils.showErrorSnackBar(context, 'خطأ في الحفظ: $e');
      }
    }
  }
}
