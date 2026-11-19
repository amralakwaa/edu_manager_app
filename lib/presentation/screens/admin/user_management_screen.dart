// ========================================
// user_management_screen.dart - إدارة المستخدمين
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../../data/models/user_model.dart';
import 'add_user_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HiveService _hive = HiveService();
  bool _isLoading = true;
  List<dynamic> _students = [];
  List<dynamic> _teachers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final students = await _hive.getStudents();
      final teachers = await _hive.getTeachers();
      if (mounted) {
        setState(() {
          _students = students;
          _teachers = teachers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في جلب البيانات: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الطلاب', icon: Icon(Icons.school)),
            Tab(text: 'المعلمون', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildUserList(_students, UserRole.student),
                  _buildUserList(_teachers, UserRole.teacher),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddUserScreen(
                    initialRole:
                        _tabController.index == 0
                            ? UserRole.student
                            : UserRole.teacher,
                  ),
            ),
          ).then((value) {
            if (value == true) _loadUsers();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserList(List<dynamic> users, UserRole role) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              role == UserRole.student ? Icons.school : Icons.person,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد ${role == UserRole.student ? 'طلاب' : 'معلمون'} حالياً',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final name = user['name'] ?? 'بدون اسم';
        final email = user['email'] ?? 'بدون بريد';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  role == UserRole.student
                      ? AppColors.studentColor.withOpacity(0.2)
                      : AppColors.teacherColor.withOpacity(0.2),
              child: Icon(
                role == UserRole.student ? Icons.school : Icons.person,
                color:
                    role == UserRole.student
                        ? AppColors.studentColor
                        : AppColors.teacherColor,
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(email),
            trailing: PopupMenuButton(
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'حذف',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
              onSelected: (val) {
                // TODO: معالجة الإجراءات
              },
            ),
          ),
        );
      },
    );
  }
}
