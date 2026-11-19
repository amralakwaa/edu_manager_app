// ========================================
// student_grades_screen.dart - درجاتي
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StudentGradesScreen extends StatelessWidget {
  const StudentGradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات تجريبية
    final List<Map<String, dynamic>> grades = [
      {
        'material': 'الرياضيات',
        'grade': '95/100',
        'status': 'ممتاز',
        'color': AppColors.success,
      },
      {
        'material': 'اللغة العربية',
        'grade': '88/100',
        'status': 'جيد جداً',
        'color': AppColors.accent,
      },
      {
        'material': 'الفيزياء',
        'grade': '75/100',
        'status': 'جيد',
        'color': AppColors.warning,
      },
      {
        'material': 'الكيمياء',
        'grade': '92/100',
        'status': 'ممتاز',
        'color': AppColors.success,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الدرجات'),
        backgroundColor: AppColors.studentColor,
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grades.length,
              itemBuilder: (context, index) => _buildGradeItem(grades[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.studentColor, AppColors.studentColorLight],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.studentColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المعدل العام',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '87.5%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(Icons.trending_up, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  Widget _buildGradeItem(Map<String, dynamic> data) {
    final Color color = data['color'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.book, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['material'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  data['status'],
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            data['grade'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
