/// ========================================
/// app_strings.dart - نصوص التطبيق
/// نظام إدارة التعليم / Education Management System
/// ========================================
///
/// جميع النصوص بالعربية والإنجليزية
/// All strings in Arabic and English

/// نصوص التطبيق - عربي + English
class AppStrings {
  AppStrings._();

  // ===== اسم التطبيق / App Name =====
  static const String appName = 'نظام إدارة التعليم';
  static const String appNameEn = 'Education Manager';

  // ===== شاشة تسجيل الدخول / Login Screen =====
  static const String login = 'تسجيل الدخول';
  static const String loginEn = 'Login';
  static const String email = 'البريد الإلكتروني';
  static const String emailEn = 'Email';
  static const String password = 'كلمة المرور';
  static const String passwordEn = 'Password';
  static const String rememberMe = 'تذكرني';
  static const String rememberMeEn = 'Remember Me';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String forgotPasswordEn = 'Forgot Password?';
  static const String loginButton = 'دخول';
  static const String loginButtonEn = 'Sign In';

  // ===== الصلاحيات / Roles =====
  static const String admin = 'مدير النظام';
  static const String adminEn = 'Admin';
  static const String teacher = 'معلم';
  static const String teacherEn = 'Teacher';
  static const String student = 'طالب';
  static const String studentEn = 'Student';
  static const String selectRole = 'اختر الصلاحية';
  static const String selectRoleEn = 'Select Role';

  // ===== لوحة التحكم / Dashboard =====
  static const String dashboard = 'لوحة التحكم';
  static const String dashboardEn = 'Dashboard';
  static const String welcome = 'مرحباً';
  static const String welcomeEn = 'Welcome';
  static const String statistics = 'الإحصائيات';
  static const String statisticsEn = 'Statistics';
  static const String quickActions = 'إجراءات سريعة';
  static const String quickActionsEn = 'Quick Actions';

  // ===== إدارة المستخدمين / User Management =====
  static const String users = 'المستخدمون';
  static const String usersEn = 'Users';
  static const String addUser = 'إضافة مستخدم';
  static const String addUserEn = 'Add User';
  static const String editUser = 'تعديل مستخدم';
  static const String editUserEn = 'Edit User';
  static const String deleteUser = 'حذف مستخدم';
  static const String deleteUserEn = 'Delete User';
  static const String totalUsers = 'إجمالي المستخدمين';
  static const String totalUsersEn = 'Total Users';

  // ===== المواد الدراسية / Materials =====
  static const String materials = 'المواد الدراسية';
  static const String materialsEn = 'Materials';
  static const String addMaterial = 'إضافة مادة';
  static const String addMaterialEn = 'Add Material';
  static const String materialName = 'اسم المادة';
  static const String materialNameEn = 'Material Name';
  static const String materialCode = 'رمز المادة';
  static const String materialCodeEn = 'Material Code';

  // ===== الواجبات / Assignments =====
  static const String assignments = 'الواجبات';
  static const String assignmentsEn = 'Assignments';
  static const String addAssignment = 'إضافة واجب';
  static const String addAssignmentEn = 'Add Assignment';
  static const String dueDate = 'تاريخ التسليم';
  static const String dueDateEn = 'Due Date';
  static const String submitted = 'تم التسليم';
  static const String submittedEn = 'Submitted';
  static const String pending = 'قيد الانتظار';
  static const String pendingEn = 'Pending';

  // ===== الدرجات / Grades =====
  static const String grades = 'الدرجات';
  static const String gradesEn = 'Grades';
  static const String addGrade = 'إضافة درجة';
  static const String addGradeEn = 'Add Grade';
  static const String totalGrade = 'الدرجة الكلية';
  static const String totalGradeEn = 'Total Grade';
  static const String average = 'المعدل';
  static const String averageEn = 'Average';

  // ===== الحضور / Attendance =====
  static const String attendance = 'الحضور والغياب';
  static const String attendanceEn = 'Attendance';
  static const String present = 'حاضر';
  static const String presentEn = 'Present';
  static const String absent = 'غائب';
  static const String absentEn = 'Absent';
  static const String late = 'متأخر';
  static const String lateEn = 'Late';
  static const String markAttendance = 'تسجيل الحضور';
  static const String markAttendanceEn = 'Mark Attendance';

  // ===== الشبكة / Network =====
  static const String network = 'الشبكة';
  static const String networkEn = 'Network';
  static const String hotspot = 'نقطة الاتصال';
  static const String hotspotEn = 'Hotspot';
  static const String enableHotspot = 'تفعيل نقطة الاتصال';
  static const String enableHotspotEn = 'Enable Hotspot';
  static const String disableHotspot = 'إيقاف نقطة الاتصال';
  static const String disableHotspotEn = 'Disable Hotspot';
  static const String connectedDevices = 'الأجهزة المتصلة';
  static const String connectedDevicesEn = 'Connected Devices';
  static const String serverUrl = 'رابط السيرفر';
  static const String serverUrlEn = 'Server URL';

  // ===== الإشعارات / Notifications =====
  static const String notifications = 'الإشعارات';
  static const String notificationsEn = 'Notifications';
  static const String noNotifications = 'لا توجد إشعارات';
  static const String noNotificationsEn = 'No Notifications';

  // ===== الإعدادات / Settings =====
  static const String settings = 'الإعدادات';
  static const String settingsEn = 'Settings';
  static const String language = 'اللغة';
  static const String languageEn = 'Language';
  static const String darkMode = 'الوضع الداكن';
  static const String darkModeEn = 'Dark Mode';
  static const String logout = 'تسجيل الخروج';
  static const String logoutEn = 'Logout';

  // ===== رسائل النجاح / Success Messages =====
  static const String success = 'تمت العملية بنجاح';
  static const String successEn = 'Operation Successful';
  static const String savedSuccessfully = 'تم الحفظ بنجاح';
  static const String savedSuccessfullyEn = 'Saved Successfully';
  static const String deletedSuccessfully = 'تم الحذف بنجاح';
  static const String deletedSuccessfullyEn = 'Deleted Successfully';

  // ===== رسائل الخطأ / Error Messages =====
  static const String error = 'حدث خطأ';
  static const String errorEn = 'Error Occurred';
  static const String connectionError = 'خطأ في الاتصال';
  static const String connectionErrorEn = 'Connection Error';
  static const String invalidCredentials = 'بيانات الدخول غير صحيحة';
  static const String invalidCredentialsEn = 'Invalid Credentials';
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String requiredFieldEn = 'This field is required';
  static const String invalidEmail = 'البريد الإلكتروني غير صالح';
  static const String invalidEmailEn = 'Invalid email address';

  // ===== أزرار عامة / General Buttons =====
  static const String save = 'حفظ';
  static const String saveEn = 'Save';
  static const String cancel = 'إلغاء';
  static const String cancelEn = 'Cancel';
  static const String confirm = 'تأكيد';
  static const String confirmEn = 'Confirm';
  static const String edit = 'تعديل';
  static const String editEn = 'Edit';
  static const String delete = 'حذف';
  static const String deleteEn = 'Delete';
  static const String search = 'بحث';
  static const String searchEn = 'Search';
  static const String filter = 'تصفية';
  static const String filterEn = 'Filter';
  static const String refresh = 'تحديث';
  static const String refreshEn = 'Refresh';
  static const String back = 'رجوع';
  static const String backEn = 'Back';
  static const String next = 'التالي';
  static const String nextEn = 'Next';
  static const String submit = 'إرسال';
  static const String submitEn = 'Submit';
}
