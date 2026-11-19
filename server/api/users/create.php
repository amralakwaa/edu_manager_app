<?php
/**
 * ========================================
 * create.php - إنشاء مستخدم جديد
 * نظام إدارة التعليم / Education Management System
 * ========================================
 */

require_once __DIR__ . '/../database.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    errorResponse('طريقة الطلب غير مسموحة', 405);
}

// التحقق من المصادقة والصلاحية
$authUser = requireRole(['admin']);

// الحصول على البيانات
$input = getJsonInput();

// التحقق من البيانات المطلوبة
$required = ['name', 'email', 'password', 'role'];
$errors = [];

foreach ($required as $field) {
    if (empty($input[$field])) {
        $errors[$field] = "حقل $field مطلوب";
    }
}

if (!empty($errors)) {
    errorResponse('بيانات غير مكتملة', 400, $errors);
}

// التحقق من صحة البريد الإلكتروني
if (!filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
    errorResponse('البريد الإلكتروني غير صالح', 400);
}

// التحقق من عدم وجود البريد الإلكتروني مسبقاً
if ($db->exists('users', 'email', $input['email'])) {
    errorResponse('البريد الإلكتروني مستخدم مسبقاً', 400);
}

// التحقق من الصلاحية
$validRoles = ['admin', 'teacher', 'student'];
if (!in_array($input['role'], $validRoles)) {
    errorResponse('الصلاحية غير صالحة', 400);
}

// إنشاء المستخدم
$userId = generateUUID();

$userData = [
    'id' => $userId,
    'name' => trim($input['name']),
    'email' => trim($input['email']),
    'password' => hashPassword($input['password']),
    'role' => $input['role'],
    'phone' => $input['phone'] ?? null,
    'is_active' => $input['is_active'] ?? true
];

$db->beginTransaction();

try {
    // إدراج المستخدم
    $db->insert('users', $userData);

    // إنشاء سجل إضافي حسب الصلاحية
    if ($input['role'] === 'teacher') {
        $teacherId = generateUUID();
        $db->insert('teachers', [
            'id' => $teacherId,
            'user_id' => $userId,
            'employee_number' => $input['employee_number'] ?? 'EMP' . substr($userId, 0, 8),
            'specialization' => $input['specialization'] ?? 'غير محدد',
            'qualification' => $input['qualification'] ?? null,
            'experience_years' => $input['experience_years'] ?? 0,
            'hire_date' => $input['hire_date'] ?? date('Y-m-d')
        ]);
    } elseif ($input['role'] === 'student') {
        $studentId = generateUUID();
        $db->insert('students', [
            'id' => $studentId,
            'user_id' => $userId,
            'student_number' => $input['student_number'] ?? 'STU' . date('Y') . substr($userId, 0, 6),
            'grade' => $input['grade'] ?? 'غير محدد',
            'section' => $input['section'] ?? null,
            'date_of_birth' => $input['date_of_birth'] ?? null,
            'gender' => $input['gender'] ?? null,
            'guardian_name' => $input['guardian_name'] ?? null,
            'guardian_phone' => $input['guardian_phone'] ?? null,
            'enrollment_date' => $input['enrollment_date'] ?? date('Y-m-d')
        ]);
    }

    $db->commit();

    // الحصول على المستخدم المُنشأ
    $newUser = $db->findById('users', $userId);
    unset($newUser['password']);

    successResponse($newUser, 'تم إنشاء المستخدم بنجاح', 201);

} catch (Exception $e) {
    $db->rollback();
    errorResponse('حدث خطأ أثناء إنشاء المستخدم', 500);
}
