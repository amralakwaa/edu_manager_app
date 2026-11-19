// ========================================
// attendance_screen.dart - رصد الحضور
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/attendance_model.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/sqlite_service.dart';
import '../../providers/user_provider.dart';

class AttendanceScreen extends StatefulWidget {
  final String materialId;
  final String materialName;

  const AttendanceScreen({
    super.key,
    required this.materialId,
    required this.materialName,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  List<StudentModel> _students = [];
  bool _isLoading = true;

  // خريطة لحفظ حالة الحضور الحالية في الواجهة
  final Map<String, String> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final hiveService = HiveService();
    final allStudents = await hiveService.getStudents();

    // محاكاة الفلترة حسب المادة (في المتطلبات الحقيقية سنستخدم الصف/المستوي)
    setState(() {
      _students = allStudents; // مؤقتاً جلب الجميع
      for (var student in _students) {
        _attendanceMap[student.id] = 'present';
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('رصد الحضور والغياب'),
            Text(
              widget.materialName,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.teacherColor,
        actions: [
          IconButton(
            onPressed: _selectDate,
            icon: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child:
                        _students.isEmpty
                            ? const Center(child: Text('لا يوجد طلاب مسجلين'))
                            : _buildStudentList(),
                  ),
                  _buildSubmitButton(),
                ],
              ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.teacherColor.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'التاريخ: ${_selectedDate.toString().split(' ').first}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'عدد الطلاب: ${_students.length}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final status = _attendanceMap[student.id];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.teacherColor.withOpacity(0.1),
              child: Text(
                student.name[0],
                style: const TextStyle(color: AppColors.teacherColor),
              ),
            ),
            title: Text(student.name),
            subtitle: Text(student.studentNumber),
            trailing: _buildStatusSelector(student.id, status!),
          ),
        );
      },
    );
  }

  Widget _buildStatusSelector(String studentId, String currentStatus) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statusIcon(
          studentId,
          'present',
          Icons.check_circle,
          AppColors.success,
          currentStatus == 'present',
        ),
        _statusIcon(
          studentId,
          'late',
          Icons.access_time_filled,
          AppColors.warning,
          currentStatus == 'late',
        ),
        _statusIcon(
          studentId,
          'absent',
          Icons.cancel,
          AppColors.error,
          currentStatus == 'absent',
        ),
      ],
    );
  }

  Widget _statusIcon(
    String studentId,
    String status,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    return IconButton(
      onPressed: () => setState(() => _attendanceMap[studentId] = status),
      icon: Icon(
        icon,
        color: isSelected ? color : color.withOpacity(0.2),
        size: 28,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitAttendance,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teacherColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'حفظ السجل',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.teacherColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitAttendance() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final sqliteService = SqliteService();
    final teacherId = userProvider.currentUser?.id ?? 'unknown';

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      for (var entry in _attendanceMap.entries) {
        final attendance = AttendanceModel(
          id: const Uuid().v4(),
          studentId: entry.key,
          materialId: widget.materialId,
          teacherId: teacherId,
          date: _selectedDate,
          status: entry.value,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await sqliteService.insertAttendance(attendance);
      }

      if (mounted) {
        Navigator.pop(context); // إغلاق مؤشر التحميل
        UIUtils.showSuccessSnackBar(context, 'تم حفظ سجل الحضور والغياب بنجاح');
        Navigator.pop(context); // العودة للخلف
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context))
          Navigator.pop(context); // إغلاق مؤشر التحميل
        UIUtils.showErrorSnackBar(context, 'خطأ في الحفظ: $e');
      }
    }
  }
}
