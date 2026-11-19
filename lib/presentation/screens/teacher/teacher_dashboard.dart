// ========================================
// teacher_dashboard.dart - لوحة تحكم المعلم
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/dashboard_card.dart';
import '../../providers/user_provider.dart';
import '../../../data/models/material_model.dart';
import '../materials/material_details_screen.dart';
import '../network_dashboard_screen.dart';
import 'attendance_screen.dart';
import 'grades_screen.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/sqlite_service.dart';
import '../../../core/utils/ui_utils.dart';

/// لوحة تحكم المعلم / Teacher Dashboard
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;

  Map<String, dynamic> _stats = {
    'myMaterials': 0,
    'myStudents': 0,
    'pendingAssignments': 0,
    'pendingGrades': 0,
    'attendanceToday': 0,
  };
  bool _isLoadingStats = true;
  List<MaterialModel> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final hive = HiveService();
    final sqlite = SqliteService();

    final materials = hive.getCachedMaterials();
    final students = await hive.getStudents();
    final submissions = hive.getAll(HiveBoxes.submissions);
    final sqliteSummary = await sqlite.getStatsSummary();

    if (mounted) {
      setState(() {
        _stats = {
          'myMaterials': materials.length,
          'myStudents': students.length,
          'pendingAssignments': submissions.length,
          'pendingGrades':
              submissions
                  .where(
                    (s) =>
                        s['status'] == 'pending' || s['status'] == 'submitted',
                  )
                  .length,
          'attendanceToday': (sqliteSummary['attendance_rate'] * 100).toInt(),
        };
        _materials = materials.map((m) => MaterialModel.fromMap(m)).toList();
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [_buildAppBar(), Expanded(child: _buildContent())],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // صورة المعلم
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.teacherColor, AppColors.teacherColorLight],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teacherColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Hero(
              tag: 'user_avatar',
              child: Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً أستاذ 👋',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Consumer<UserProvider>(
                builder: (context, provider, _) {
                  return Text(
                    provider.currentUser?.name ?? 'المعلم',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          // أيقونة الإشعارات
          _buildNotificationIcon(),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NetworkDashboardScreen(),
                  ),
                ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings_ethernet,
                color: AppColors.teacherColor,
                size: 20,
              ),
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // إحصائيات سريعة
          _buildStatsGrid(),
          const SizedBox(height: 24),

          // حصص اليوم
          _buildTodayClasses(),
          const SizedBox(height: 24),

          // واجبات تحتاج تقييم
          _buildPendingGrades(),
          const SizedBox(height: 24),

          // إجراءات سريعة
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نظرة عامة',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children:
              _isLoadingStats
                  ? List.generate(4, (index) => _buildStatShimmer())
                  : [
                    DashboardCard(
                      title: 'موادي الدراسية',
                      value: '${_stats['myMaterials']}',
                      icon: Icons.book,
                      iconColor: AppColors.teacherColor,
                      heroTag: 'stat_materials',
                      onTap: () {
                        if (_materials.isNotEmpty) {
                          _navigateToMaterialDetail(_materials.first);
                        } else {
                          UIUtils.showInfoSnackBar(
                            context,
                            'لا توجد مواد دراسية حالياً',
                          );
                        }
                      },
                    ),
                    DashboardCard(
                      title: 'طلابي',
                      value: '${_stats['myStudents']}',
                      icon: Icons.people,
                      iconColor: AppColors.studentColor,
                      heroTag: 'stat_students',
                      onTap: () {},
                    ),
                    DashboardCard(
                      title: 'واجبات للتقييم',
                      value: '${_stats['pendingGrades']}',
                      icon: Icons.assignment_turned_in,
                      iconColor: AppColors.warning,
                      heroTag: 'stat_assignments',
                      onTap: () {},
                    ),
                    DashboardCard(
                      title: 'حضور اليوم',
                      value: '${_stats['attendanceToday']}%',
                      icon: Icons.check_circle,
                      iconColor: AppColors.success,
                      heroTag: 'stat_attendance',
                      onTap: () {
                        // نفتح سجل الحضور الشامل أو شاشة الحضور
                      },
                    ),
                  ],
        ),
      ],
    );
  }

  Widget _buildStatShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  void _navigateToMaterialDetail(MaterialModel material) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                MaterialDetailsScreen(material: material, isTeacher: true),
      ),
    );
  }

  Widget _buildTodayClasses() {
    final classes = [
      {
        'name': 'الرياضيات',
        'grade': 'الصف العاشر أ',
        'time': '08:00 - 09:00',
        'status': 'completed',
      },
      {
        'name': 'الرياضيات',
        'grade': 'الصف العاشر ب',
        'time': '09:15 - 10:15',
        'status': 'current',
      },
      {
        'name': 'الرياضيات',
        'grade': 'الصف الحادي عشر',
        'time': '11:00 - 12:00',
        'status': 'upcoming',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'حصص اليوم',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_today, size: 16),
              label: const Text('الجدول الكامل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...classes.map((c) => _buildClassCard(c)),
      ],
    );
  }

  Widget _buildClassCard(Map<String, String> classData) {
    final isCurrent = classData['status'] == 'current';
    final isCompleted = classData['status'] == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isCurrent
                ? AppColors.teacherColor.withOpacity(0.15)
                : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border:
            isCurrent
                ? Border.all(color: AppColors.teacherColor, width: 2)
                : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.teacherColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.book,
              color: isCompleted ? AppColors.success : AppColors.teacherColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classData['name']!,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  classData['grade']!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                classData['time']!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.teacherColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'الآن',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingGrades() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'واجبات تحتاج تقييم',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_stats['pendingGrades']}',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildPendingItem('واجب الجبر', 'الصف العاشر', '15 تسليم'),
              const Divider(color: AppColors.glassBackground),
              _buildPendingItem(
                'اختبار الهندسة',
                'الصف الحادي عشر',
                '22 تسليم',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingItem(String title, String grade, String submissions) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.assignment, color: AppColors.warning),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '$grade • $submissions',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: TextButton(onPressed: () {}, child: const Text('تقييم')),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إجراءات سريعة',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              'تسجيل الحضور',
              Icons.fact_check,
              AppColors.success,
            ),
            _buildActionButton('إضافة واجب', Icons.add_task, AppColors.accent),
            _buildActionButton(
              'إدخال درجات',
              Icons.edit_note,
              AppColors.warning,
            ),
            _buildActionButton('مراسلة ولي أمر', Icons.message, AppColors.info),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            label == 'تسجيل الحضور'
                ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const AttendanceScreen(
                          materialId: 'math101',
                          materialName: 'الرياضيات - الصف العاشر',
                        ),
                  ),
                )
                : label == 'إدخال درجات'
                ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const GradesScreen(
                          materialId: 'math101',
                          materialName: 'الرياضيات - الصف العاشر',
                        ),
                  ),
                )
                : () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.teacherColor,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'موادي'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'طلابي'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'الواجبات',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
