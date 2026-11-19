// ========================================
// admin_dashboard.dart - لوحة تحكم المدير
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/dashboard_card.dart';
import '../../providers/user_provider.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/sqlite_service.dart';
import '../../../data/models/assignment_model.dart';
import 'package:intl/intl.dart' as intl;
import 'user_management_screen.dart';
import 'add_user_screen.dart';
import '../../../data/models/user_model.dart';
import '../../../core/services/hotspot_service.dart';
import 'add_material_screen.dart';
import '../../../core/utils/ui_utils.dart';

/// لوحة تحكم المدير / Admin Dashboard
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedIndex = 0;
  Map<String, dynamic> _stats = {
    'totalStudents': 0,
    'totalTeachers': 0,
    'totalMaterials': 0,
    'activeAssignments': 0,
    'attendanceRate': 0,
    'averageGrade': 0,
  };
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final hive = HiveService();
    final sqlite = SqliteService();

    final students = await hive.getStudents();
    final teachers = await hive.getTeachers();
    final materials = hive.getCachedMaterials();
    final assignments = hive.getCachedAssignments();
    final sqliteSummary = await sqlite.getStatsSummary();
    final logs = await sqlite.getLoginLogs(limit: 5);

    if (mounted) {
      setState(() {
        _stats = {
          'totalStudents': students.length,
          'totalTeachers': teachers.length,
          'totalMaterials': materials.length,
          'activeAssignments':
              assignments.where((a) {
                final model = AssignmentModel.fromMap(a);
                return model.isOpen;
              }).length,
          'attendanceRate': (sqliteSummary['attendance_rate'] * 100).toInt(),
          'averageGrade': (sqliteSummary['average_grade'] * 100).toInt(),
        };

        _activities =
            logs
                .map(
                  (log) => {
                    'title': 'تسجيل دخول: ${log['user_id']}',
                    'time': _formatTimestamp(log['timestamp']),
                    'icon': Icons.login,
                  },
                )
                .toList();

        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
      return intl.DateFormat('yyyy/MM/dd HH:mm').format(date);
    } catch (_) {
      return timestamp;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Row(
            children: [
              // Sidebar للويب
              if (isWeb) _buildSidebar(),

              // المحتوى الرئيسي
              Expanded(
                child: Column(
                  children: [
                    _buildAppBar(isWeb),
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation للموبايل
      bottomNavigationBar: isWeb ? null : _buildBottomNav(),
      drawer: isWeb ? null : _buildDrawer(),
    );
  }

  Widget _buildAppBar(bool isWeb) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (!isWeb)
            Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
            ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.welcome} 👋',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              Consumer<UserProvider>(
                builder: (context, provider, _) {
                  return Text(
                    provider.currentUser?.name ?? 'مدير النظام',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
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
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  // TODO: شاشة الإشعارات
                },
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
          ),
          // صورة المستخدم
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // الشعار
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Hero(
              tag: 'app_logo',
              child: Icon(Icons.school, size: 32, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.appName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // عناصر القائمة
          _buildSidebarItem(0, Icons.dashboard, 'لوحة التحكم'),
          _buildSidebarItem(
            1,
            Icons.people,
            'المستخدمون',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserManagementScreen(),
                ),
              );
            },
          ),
          _buildSidebarItem(2, Icons.school, 'الطلاب'),
          _buildSidebarItem(3, Icons.person, 'المعلمون'),
          _buildSidebarItem(4, Icons.book, 'المواد'),
          _buildSidebarItem(5, Icons.bar_chart, 'الإحصائيات'),
          _buildSidebarItem(6, Icons.wifi_tethering, 'الشبكة'),
          _buildSidebarItem(7, Icons.settings, 'الإعدادات'),

          const Spacer(),

          // تسجيل الخروج
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    int index,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.accent : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.accent.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap:
            onTap ??
            () {
              setState(() {
                _selectedIndex = index;
              });
            },
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          const Text(
            'نظرة عامة',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // بطاقات الإحصائيات
          _buildStatsGrid(),
          const SizedBox(height: 32),

          // الإجراءات السريعة
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 32),

          // أحدث النشاطات
          const Text(
            'أحدث النشاطات',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children:
              _isLoading
                  ? List.generate(6, (index) => _buildStatShimmer())
                  : [
                    DashboardCard(
                      title: 'إجمالي الطلاب',
                      value: '${_stats['totalStudents']}',
                      icon: Icons.school,
                      iconColor: AppColors.studentColor,
                      subtitle: 'الطلاب المسجلين',
                    ),
                    DashboardCard(
                      title: 'إجمالي المعلمين',
                      value: '${_stats['totalTeachers']}',
                      icon: Icons.person,
                      iconColor: AppColors.teacherColor,
                      subtitle: 'طاقم العمل',
                    ),
                    DashboardCard(
                      title: 'المواد الدراسية',
                      value: '${_stats['totalMaterials']}',
                      icon: Icons.book,
                      iconColor: AppColors.accent,
                    ),
                    DashboardCard(
                      title: 'الواجبات النشطة',
                      value: '${_stats['activeAssignments']}',
                      icon: Icons.assignment,
                      iconColor: AppColors.warning,
                    ),
                    DashboardCard(
                      title: 'نسبة الحضور',
                      value: '${_stats['attendanceRate']}%',
                      icon: Icons.check_circle,
                      iconColor: AppColors.success,
                    ),
                    DashboardCard(
                      title: 'متوسط الدرجات',
                      value: '${_stats['averageGrade']}%',
                      icon: Icons.grade,
                      iconColor: AppColors.secondary,
                    ),
                  ],
        );
      },
    );
  }

  Widget _buildStatShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        QuickActionCard(
          title: 'إضافة طالب',
          icon: Icons.person_add,
          color: AppColors.studentColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        const AddUserScreen(initialRole: UserRole.student),
              ),
            ).then((_) => _loadDashboardData());
          },
        ),
        QuickActionCard(
          title: 'إضافة معلم',
          icon: Icons.person_add_alt,
          color: AppColors.teacherColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        const AddUserScreen(initialRole: UserRole.teacher),
              ),
            ).then((_) => _loadDashboardData());
          },
        ),
        QuickActionCard(
          title: 'إضافة مادة',
          icon: Icons.book,
          color: AppColors.accent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddMaterialScreen(),
              ),
            ).then((_) => _loadDashboardData());
          },
        ),
        QuickActionCard(
          title: 'تفعيل Hotspot',
          icon: Icons.wifi_tethering,
          color: AppColors.warning,
          onTap: () async {
            final hotspot = HotspotService();
            final isEnabled = await hotspot.isHotspotEnabled();

            if (mounted) {
              if (isEnabled) {
                await hotspot.disableHotspot();
                UIUtils.showInfoSnackBar(context, 'تم إيقاف الـ Hotspot');
              } else {
                final success = await hotspot.enableHotspot();
                if (success) {
                  UIUtils.showSuccessSnackBar(
                    context,
                    'تم تفعيل الـ Hotspot بنجاح',
                  );
                } else {
                  UIUtils.showErrorSnackBar(
                    context,
                    'فشل تفعيل الـ Hotspot - تأكد من الصلاحيات',
                  );
                }
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activities.length,
                separatorBuilder:
                    (_, __) => const Divider(color: AppColors.glassBackground),
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        activity['icon'] as IconData,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      activity['title'] as String,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      activity['time'] as String,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                },
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
        currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserManagementScreen(),
              ),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'المستخدمون',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'المواد'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.backgroundDark,
      child: _buildSidebar(),
    );
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              'هل أنت متأكد من تسجيل الخروج؟',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'خروج',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      await context.read<UserProvider>().logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
