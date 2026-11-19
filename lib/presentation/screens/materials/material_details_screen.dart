// ========================================
// material_details_screen.dart - تفاصيل المادة
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/material_model.dart';
import '../../../data/models/assignment_model.dart';
import '../student/assignment_submission_screen.dart';

class MaterialDetailsScreen extends StatefulWidget {
  final MaterialModel material;
  final bool isTeacher;

  const MaterialDetailsScreen({
    super.key,
    required this.material,
    this.isTeacher = false,
  });

  @override
  State<MaterialDetailsScreen> createState() => _MaterialDetailsScreenState();
}

class _MaterialDetailsScreenState extends State<MaterialDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // بيانات تجريبية (سيتم استبدالها لاحقاً بالخدمات)
  final List<AssignmentModel> _assignments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isTeacher ? 4 : 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
        widget.isTeacher ? AppColors.teacherColor : AppColors.studentColor;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(themeColor),
          SliverToBoxAdapter(child: _buildTabBar(themeColor)),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAssignmentsTab(),
                _buildFilesTab(),
                if (widget.isTeacher) _buildAttendanceTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          widget.isTeacher ? _buildTeacherFAB(themeColor) : null,
    );
  }

  Widget _buildAppBar(Color themeColor) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: themeColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.material.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [themeColor.withOpacity(0.8), themeColor],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Icon(
                Icons.book_outlined,
                size: 200,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    widget.material.code,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.material.grade} • ${widget.material.semester}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(Color themeColor) {
    return Container(
      color: AppColors.cardBackground,
      child: TabBar(
        controller: _tabController,
        labelColor: themeColor,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: themeColor,
        indicatorWeight: 3,
        tabs: [
          const Tab(text: 'نظرة عامة'),
          const Tab(text: 'الواجبات'),
          const Tab(text: 'الملفات'),
          if (widget.isTeacher) const Tab(text: 'الحضور'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'عن المادة',
            widget.material.description ?? 'لا يوجد وصف متاح هذه المادة.',
          ),
          const SizedBox(height: 24),
          _buildScheduleInfo(),
          const SizedBox(height: 24),
          _buildMarksInfo(),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            content,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مواعيد المحاضرات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.accent),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.material.days.join('، '),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.material.startTime ?? "00:00"} - ${widget.material.endTime ?? "00:00"}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarksInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildMarkCard(
            'الدرجة الكلية',
            '${widget.material.totalMarks}',
            AppColors.accent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMarkCard(
            'درجة النجاح',
            '${widget.material.passingMarks}',
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsTab() {
    if (_assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا يوجد واجبات حالياً',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _assignments.length,
      itemBuilder:
          (context, index) => _buildAssignmentItem(_assignments[index]),
    );
  }

  Widget _buildAssignmentItem(AssignmentModel assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(assignment.title),
        subtitle: Text(
          'موعد التسليم: ${assignment.dueDate.toString().split(' ').first}',
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: () {
          if (!widget.isTeacher) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AssignmentSubmissionScreen(assignment: assignment),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFilesTab() {
    return const Center(child: Text('قريباً: رفع وتحميل الملفات والملازم'));
  }

  Widget _buildAttendanceTab() {
    return const Center(child: Text('قريباً: رصد الحضور والغياب لهذه المادة'));
  }

  Widget _buildTeacherFAB(Color themeColor) {
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: themeColor,
      icon: const Icon(Icons.add),
      label: const Text('إجراء جديد'),
    );
  }
}
