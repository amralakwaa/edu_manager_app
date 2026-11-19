<?php
/**
 * ========================================
 * login.php - تسجيل الدخول
 * نظام إدارة التعليم / Education Management System
 * ========================================
 */

require_once __DIR__ . '/../database.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    errorResponse('طريقة الطلب غير مسموحة', 405);
}

// الحصول على البيانات
$input = getJsonInput();

// التحقق من البيانات المطلوبة
if (empty($input['email']) || empty($input['password'])) {
    errorResponse('البريد الإلكتروني وكلمة المرور مطلوبان', 400);
}

$email = trim($input['email']);
$password = $input['password'];
$deviceId = $input['device_id'] ?? null;

// البحث عن المستخدم
$user = $db->queryOne(
    "SELECT * FROM users WHERE email = ? AND is_active = TRUE",
    [$email]
);

if (!$user) {
    errorResponse('البريد الإلكتروني أو كلمة المرور غير صحيحة', 401);
}

// التحقق من كلمة المرور
if (!verifyPassword($password, $user['password'])) {
    errorResponse('البريد الإلكتروني أو كلمة المرور غير صحيحة', 401);
}

// إنشاء التوكن
$token = createToken($user['id'], $user['role']);

// تحديث معلومات تسجيل الدخول
$db->update(
    'users',
    [
        'last_login' => date('Y-m-d H:i:s'),
        'device_id' => $deviceId
    ],
    'id = :id',
    ['id' => $user['id']]
);

// حفظ التوكن في قاعدة البيانات
$tokenId = generateUUID();
$expiresAt = date('Y-m-d H:i:s', time() + JWT_EXPIRY);

$db->insert('tokens', [
    'id' => $tokenId,
    'user_id' => $user['id'],
    'token' => $token,
    'device_id' => $deviceId,
    'expires_at' => $expiresAt
]);

// الحصول على بيانات إضافية حسب الصلاحية
$additionalData = null;

if ($user['role'] === 'teacher') {
    $additionalData = $db->queryOne(
        "SELECT * FROM teachers WHERE user_id = ?",
        [$user['id']]
    );
} elseif ($user['role'] === 'student') {
    $additionalData = $db->queryOne(
        "SELECT * FROM students WHERE user_id = ?",
        [$user['id']]
    );
}

// إزالة كلمة المرور من الاستجابة
unset($user['password']);

// إرجاع الاستجابة
successResponse([
    'user' => $user,
    'token' => $token,
    'expires_at' => $expiresAt,
    'role_data' => $additionalData
], 'تم تسجيل الدخول بنجاح');
