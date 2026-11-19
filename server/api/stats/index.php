<?php
/**
 * ========================================
 * index.php - الإحصائيات العامة
 * نظام إدارة التعليم / Education Management System
 * ========================================
 */

require_once __DIR__ . '/../database.php';

// التحقق من المصادقة
$authUser = requireAuth();

// الحصول على الإحصائيات حسب الصلاحية
$stats = [];

// إحصائيات عامة
$stats['total_users'] = $db->count('users', 'is_active = 1');
$stats['total_students'] = $db->count('users', "role = 'student' AND is_active = 1");
$stats['total_teachers'] = $db->count('users', "role = 'teacher' AND is_active = 1");
$stats['total_materials'] = $db->count('materials', "status = 'active'");
$stats['total_assignments'] = $db->count('assignments');
$stats['pending_assignments'] = $db->count('assignments', "status = 'published' AND due_date > NOW()");

// متوسط الدرجات
$avgGrade = $db->queryOne("SELECT AVG(percentage) as avg FROM grades");
$stats['average_grade'] = round($avgGrade['avg'] ?? 0, 2);

// نسبة الحضور
$attendanceStats = $db->queryOne("
    SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present
    FROM attendance 
    WHERE date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
");

if ($attendanceStats && $attendanceStats['total'] > 0) {
    $stats['attendance_rate'] = round(
        ($attendanceStats['present'] / $attendanceStats['total']) * 100,
        2
    );
} else {
    $stats['attendance_rate'] = 0;
}

// تسجيلات الدخول اليوم
$stats['today_logins'] = $db->count(
    'users',
    "DATE(last_login) = CURDATE()"
);

// إحصائيات إضافية للـ Admin
if ($authUser['role'] === 'admin') {
    // أحدث التسجيلات
    $stats['recent_users'] = $db->query(
        "SELECT id, name, email, role, created_at 
         FROM users 
         ORDER BY created_at DESC 
         LIMIT 5"
    );

    // توزيع الأدوار
    $roleDistribution = $db->query(
        "SELECT role, COUNT(*) as count 
         FROM users 
         WHERE is_active = 1 
         GROUP BY role"
    );
    $stats['role_distribution'] = $roleDistribution;
}

// إحصائيات للمعلم
if ($authUser['role'] === 'teacher') {
    // الحصول على معرف المعلم
    $teacher = $db->queryOne(
        "SELECT id FROM teachers WHERE user_id = ?",
        [$authUser['user_id']]
    );

    if ($teacher) {
        $stats['my_materials'] = $db->count('materials', "teacher_id = ?", [$teacher['id']]);
        $stats['my_assignments'] = $db->count('assignments', "teacher_id = ?", [$teacher['id']]);

        // الواجبات التي تحتاج تقييم
        $pendingSubmissions = $db->queryOne("
            SELECT COUNT(*) as count 
            FROM submissions s
            JOIN assignments a ON s.assignment_id = a.id
            WHERE a.teacher_id = ? AND s.status = 'submitted'
        ", [$teacher['id']]);
        $stats['pending_grading'] = $pendingSubmissions['count'] ?? 0;
    }
}

// إحصائيات للطالب
if ($authUser['role'] === 'student') {
    // الحصول على معرف الطالب
    $student = $db->queryOne(
        "SELECT id FROM students WHERE user_id = ?",
        [$authUser['user_id']]
    );

    if ($student) {
        $stats['enrolled_materials'] = $db->count('enrollments', "student_id = ?", [$student['id']]);

        // واجباتي المعلقة
        $pendingAssignments = $db->queryOne("
            SELECT COUNT(*) as count 
            FROM assignments a
            JOIN enrollments e ON a.material_id = e.material_id
            LEFT JOIN submissions s ON a.id = s.assignment_id AND s.student_id = ?
            WHERE e.student_id = ? 
              AND a.status = 'published' 
              AND a.due_date > NOW()
              AND s.id IS NULL
        ", [$student['id'], $student['id']]);
        $stats['pending_assignments'] = $pendingAssignments['count'] ?? 0;

        // معدلي
        $myAvg = $db->queryOne(
            "SELECT AVG(percentage) as avg FROM grades WHERE student_id = ?",
            [$student['id']]
        );
        $stats['my_average'] = round($myAvg['avg'] ?? 0, 2);

        // نسبة حضوري
        $myAttendance = $db->queryOne("
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present
            FROM attendance 
            WHERE student_id = ?
        ", [$student['id']]);

        if ($myAttendance && $myAttendance['total'] > 0) {
            $stats['my_attendance'] = round(
                ($myAttendance['present'] / $myAttendance['total']) * 100,
                2
            );
        } else {
            $stats['my_attendance'] = 0;
        }
    }
}

successResponse($stats);
