/// ========================================
/// api_endpoints.dart - روابط API
/// نظام إدارة التعليم / Education Management System
/// ========================================
///
/// جميع روابط API للتواصل مع السيرفر المحلي PHP/MySQL

/// روابط API / API Endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // ===== السيرفر الأساسي / Base Server =====

  /// الرابط الأساسي للسيرفر المحلي
  /// قم بتغييره حسب إعداداتك
  /// Change this according to your XAMPP setup
  static const String baseUrl = 'http://192.168.100.200:8080/edu_manager/api';

  /// الرابط للويب (نفس الرابط أو سيرفر آخر)
  static const String webBaseUrl =
      'http://192.168.100.200:8080/edu_manager/api';

  /// رابط WebSocket للاتصال الفوري
  static const String wsUrl = 'ws://192.168.100.200:8080';

  // ===== المصادقة / Authentication =====

  /// تسجيل الدخول
  static const String login = '/auth/login.php';

  /// تسجيل مستخدم جديد
  static const String register = '/auth/register.php';

  /// تسجيل الخروج
  static const String logout = '/auth/logout.php';

  /// التحقق من التوكن
  static const String verifyToken = '/auth/verify.php';

  /// استعادة كلمة المرور
  static const String resetPassword = '/auth/reset_password.php';

  // ===== المستخدمون / Users =====

  /// قائمة المستخدمين
  static const String users = '/users/index.php';

  /// مستخدم واحد
  static String user(String id) => '/users/show.php?id=$id';

  /// إنشاء مستخدم
  static const String createUser = '/users/create.php';

  /// تحديث مستخدم
  static const String updateUser = '/users/update.php';

  /// حذف مستخدم
  static const String deleteUser = '/users/delete.php';

  // ===== الطلاب / Students =====

  /// قائمة الطلاب
  static const String students = '/students/index.php';

  /// طالب واحد
  static String student(String id) => '/students/show.php?id=$id';

  // ===== المعلمون / Teachers =====

  /// قائمة المعلمين
  static const String teachers = '/teachers/index.php';

  /// معلم واحد
  static String teacher(String id) => '/teachers/show.php?id=$id';

  // ===== المواد الدراسية / Materials =====

  /// قائمة المواد
  static const String materials = '/materials/index.php';

  /// مادة واحدة
  static String material(String id) => '/materials/show.php?id=$id';

  /// إنشاء مادة
  static const String createMaterial = '/materials/create.php';

  /// تحديث مادة
  static const String updateMaterial = '/materials/update.php';

  /// حذف مادة
  static const String deleteMaterial = '/materials/delete.php';

  // ===== الواجبات / Assignments =====

  /// قائمة الواجبات
  static const String assignments = '/assignments/index.php';

  /// واجب واحد
  static String assignment(String id) => '/assignments/show.php?id=$id';

  /// إنشاء واجب
  static const String createAssignment = '/assignments/create.php';

  /// تحديث واجب
  static const String updateAssignment = '/assignments/update.php';

  /// حذف واجب
  static const String deleteAssignment = '/assignments/delete.php';

  /// تسليم واجب
  static const String submitAssignment = '/assignments/submit.php';

  // ===== الدرجات / Grades =====

  /// قائمة الدرجات
  static const String grades = '/grades/index.php';

  /// درجات طالب
  static String studentGrades(String studentId) =>
      '/grades/student.php?id=$studentId';

  /// إضافة درجة
  static const String addGrade = '/grades/create.php';

  /// تحديث درجة
  static const String updateGrade = '/grades/update.php';

  // ===== الحضور / Attendance =====

  /// سجل الحضور
  static const String attendance = '/attendance/index.php';

  /// حضور يوم محدد
  static String attendanceByDate(String date) =>
      '/attendance/date.php?date=$date';

  /// تسجيل الحضور
  static const String markAttendance = '/attendance/mark.php';

  // ===== الإحصائيات / Statistics =====

  /// إحصائيات عامة
  static const String stats = '/stats/index.php';

  /// إحصائيات Admin
  static const String adminStats = '/stats/admin.php';

  /// إحصائيات Teacher
  static const String teacherStats = '/stats/teacher.php';

  /// إحصائيات Student
  static const String studentStats = '/stats/student.php';

  // ===== المزامنة / Sync =====

  /// مزامنة البيانات
  static const String sync = '/sync/index.php';

  /// آخر تحديث
  static const String lastSync = '/sync/last.php';
}
