// ========================================
// student_dashboard.dart - لوحة تحكم الطالب
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/dashboard_card.dart';
import '../../providers/user_provider.dart';
import '../../../data/models/material_model.dart';
import '../../../data/models/assignment_model.dart';
import '../materials/material_details_screen.dart';
import 'student_grades_screen.dart';
import 'assignment_submission_screen.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/sqlite_service.dart';

/// لوحة تحكم الطالب / Student Dashboard
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  Map<String, dynamic> _stats = {
    'enrolledMaterials': 0,
    'pendingAssignments': 0,
    'myAverage': 0.0,
    'attendanceRate': 0,
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentId = userProvider.currentUser?.id ?? 'unknown';

    final materialsData = hive.getCachedMaterials();
    final materials =
        materialsData.map((m) => MaterialModel.fromMap(m)).toList();
    final assignments = hive.getCachedAssignments();
    final submissions = hive.getAll(HiveBoxes.submissions);

    // حساب المعدل من SQLite
    final grades = await sqlite.getStudentGrades(studentId);
    double avg = 0;
    if (grades.isNotEmpty) {
      avg =
          grades.map((g) => g.percentage).reduce((a, b) => a + b) /
          grades.length;
    }

    // حساب نسبة الحضور
    final attendance = await sqlite.getStudentAttendance(studentId);
    int attRate = 0;
    if (attendance.isNotEmpty) {
      final presentCount =
          attendance
              .where((a) => a.status == 'present' || a.status == 'late')
              .length;
      attRate = ((presentCount / attendance.length) * 100).toInt();
    }

    if (mounted) {
      setState(() {
        _stats = {
          'enrolledMaterials': materials.length,
          'pendingAssignments':
              assignments.length - submissions.length, // تبسيط
          'myAverage': double.parse(avg.toStringAsFixed(1)),
          'attendanceRate': attRate,
        };
        _materials = materials;
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
          // صورة الطالب
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.studentColor, AppColors.studentColorLight],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.studentColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Hero(
              tag: 'app_logo',
              child: Icon(Icons.school, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً 👋',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Consumer<UserProvider>(
                builder: (context, provider, _) {
                  return Text(
                    provider.currentUser?.name ?? 'الطالب',
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
          Stack(
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
                right: 8,
                top: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة المعدل
          _isLoadingStats
              ? const Center(child: CircularProgressIndicator())
              : _buildGpaCard(),
          const SizedBox(height: 24),

          // إحصائيات سريعة
          _buildMiniStats(),
          const SizedBox(height: 24),

          // الواجبات المعلقة
          _buildPendingAssignments(),
          const SizedBox(height: 24),

          // الحصص القادمة
          _buildUpcomingClasses(),
          const SizedBox(height: 24),

          // موادي
          _buildMyMaterials(),
        ],
      ),
    );
  }

  Widget _buildGpaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.studentColor, AppColors.studentColorLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.studentColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Hero(
        tag: 'gpa_card',
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'معدلي التراكمي',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ممتاز',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_stats['myAverage']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, right: 4),
                    child: Text(
                      '%',
                      style: TextStyle(color: Colors.white70, fontSize: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // شريط التقدم
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _stats['myAverage'] / 100,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStats() {
    return Row(
      children: [
        Expanded(
          child: MiniStatsCard(
            label: 'نسبة الحضور',
            value: '${_stats['attendanceRate']}%',
            icon: Icons.check_circle,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MiniStatsCard(
            label: 'واجبات معلقة',
            value: '${_stats['pendingAssignments']}',
            icon: Icons.assignment_late,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingAssignments() {
    final assignments = [
      {
        'title': 'واجب الجبر',
        'material': 'الرياضيات',
        'dueDate': 'غداً',
        'urgent': true,
      },
      {
        'title': 'بحث الأدب',
        'material': 'اللغة العربية',
        'dueDate': 'بعد 3 أيام',
        'urgent': false,
      },
      {
        'title': 'تقرير الفيزياء',
        'material': 'الفيزياء',
        'dueDate': 'بعد أسبوع',
        'urgent': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'واجباتي المعلقة',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('عرض الكل')),
          ],
        ),
        const SizedBox(height: 12),
        ...assignments.map((a) => _buildAssignmentCard(a)),
      ],
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final isUrgent = assignment['urgent'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: isUrgent ? Border.all(color: AppColors.error, width: 1) : null,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AssignmentSubmissionScreen(
                    assignment: AssignmentModel(
                      id: 'a1',
                      title: assignment['title'] as String,
                      description: 'هذا وصف توضيحي للواجب المطلوب تسليمه.',
                      materialId: 'm1',
                      teacherId: 't1',
                      grade: 'الصف العاشر',
                      startDate: DateTime.now(),
                      dueDate: DateTime.now().add(const Duration(days: 2)),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isUrgent ? AppColors.error : AppColors.accent)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUrgent ? Icons.warning : Icons.assignment,
                color: isUrgent ? AppColors.error : AppColors.accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment['title'] as String,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assignment['material'] as String,
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
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'عاجل',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  assignment['dueDate'] as String,
                  style: TextStyle(
                    color: isUrgent ? AppColors.error : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingClasses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'حصص اليوم',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildClassChip('الرياضيات', '08:00', true),
              _buildClassChip('اللغة العربية', '09:15', false),
              _buildClassChip('الفيزياء', '11:00', false),
              _buildClassChip('الكيمياء', '12:30', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassChip(String name, String time, bool isNext) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext ? AppColors.studentColor : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.book,
            color: isNext ? Colors.white : AppColors.textSecondary,
            size: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isNext ? Colors.white : AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                time,
                style: TextStyle(
                  color: isNext ? Colors.white70 : AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyMaterials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'موادي الدراسية',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('عرض الكل')),
          ],
        ),
        const SizedBox(height: 12),
        if (_materials.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'لا توجد مواد مسجلة حالياً',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: _materials.length > 6 ? 6 : _materials.length,
            itemBuilder: (context, index) {
              final m = _materials[index];
              return _buildMaterialIcon(
                m.name,
                Icons.book,
                AppColors.accent,
                m,
              );
            },
          ),
      ],
    );
  }

  Widget _buildMaterialIcon(
    String name,
    IconData icon,
    Color color,
    MaterialModel material,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MaterialDetailsScreen(
                      material: material,
                      isTeacher: false,
                    ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
        onTap: (index) {
          if (index == 3) {
            // صفحة الدرجات
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentGradesScreen(),
              ),
            );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.studentColor,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'موادي'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'واجباتي',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'درجاتي'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
