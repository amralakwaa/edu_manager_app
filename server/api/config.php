<?php
/**
 * ========================================
 * config.php - إعدادات السيرفر
 * نظام إدارة التعليم / Education Management System
 * ========================================
 * 
 * تعليمات التثبيت:
 * 1. انسخ مجلد server إلى C:\xampp\htdocs\edu_manager
 * 2. قم بتعديل بيانات الاتصال أدناه حسب إعداداتك
 * 3. تأكد من تشغيل Apache و MySQL في XAMPP
 */

// ===== إعدادات قاعدة البيانات / Database Settings =====
define('DB_HOST', 'localhost');
define('DB_NAME', 'edu_manager');
define('DB_USER', 'root');
define('DB_PASS', ''); // كلمة مرور MySQL (فارغة افتراضياً في XAMPP)
define('DB_CHARSET', 'utf8mb4');

// ===== إعدادات التطبيق / Application Settings =====
define('APP_NAME', 'نظام إدارة التعليم');
define('APP_VERSION', '1.0.0');
define('APP_DEBUG', true); // غيّرها إلى false في الإنتاج

// ===== إعدادات الأمان / Security Settings =====
define('JWT_SECRET', 'your-super-secret-key-change-this-in-production'); // غيّر هذا المفتاح!
define('JWT_EXPIRY', 86400); // 24 ساعة بالثواني
define('PASSWORD_COST', 12); // تكلفة bcrypt

// ===== إعدادات CORS / CORS Settings =====
define('ALLOWED_ORIGINS', [
    'http://localhost',
    'http://localhost:8080',
    'http://127.0.0.1',
    'http://127.0.0.1:8081',
    'http://192.168.10.71:8081',
    'http://192.168.100.200:8081',
    'http://localhost:8081',
    '*' // للتطوير فقط، احذف هذا في الإنتاج
]);

// ===== إعدادات الرفع / Upload Settings =====
define('UPLOAD_DIR', __DIR__ . '/../uploads/');
define('MAX_FILE_SIZE', 10 * 1024 * 1024); // 10 ميجابايت
define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx']);

// ===== إعدادات المنطقة الزمنية / Timezone Settings =====
date_default_timezone_set('Asia/Riyadh');

// ===== دوال مساعدة / Helper Functions =====

/**
 * إرجاع استجابة JSON
 */
function jsonResponse($data, $statusCode = 200)
{
    http_response_code($statusCode);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

/**
 * إرجاع استجابة نجاح
 */
function successResponse($data = null, $message = 'تمت العملية بنجاح', $statusCode = 200)
{
    jsonResponse([
        'success' => true,
        'message' => $message,
        'data' => $data
    ], $statusCode);
}

/**
 * إرجاع استجابة خطأ
 */
function errorResponse($message, $statusCode = 400, $errors = null)
{
    jsonResponse([
        'success' => false,
        'message' => $message,
        'errors' => $errors
    ], $statusCode);
}

/**
 * الحصول على بيانات الطلب JSON
 */
function getJsonInput()
{
    $input = file_get_contents('php://input');
    return json_decode($input, true) ?? [];
}

/**
 * توليد UUID
 */
function generateUUID()
{
    return sprintf(
        '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0x0fff) | 0x4000,
        mt_rand(0, 0x3fff) | 0x8000,
        mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0xffff)
    );
}

/**
 * تشفير كلمة المرور
 */
function hashPassword($password)
{
    return password_hash($password, PASSWORD_BCRYPT, ['cost' => PASSWORD_COST]);
}

/**
 * التحقق من كلمة المرور
 */
function verifyPassword($password, $hash)
{
    return password_verify($password, $hash);
}

/**
 * إنشاء توكن JWT
 */
function createToken($userId, $role)
{
    $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
    $payload = json_encode([
        'user_id' => $userId,
        'role' => $role,
        'iat' => time(),
        'exp' => time() + JWT_EXPIRY
    ]);

    $base64Header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
    $base64Payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

    $signature = hash_hmac('sha256', "$base64Header.$base64Payload", JWT_SECRET, true);
    $base64Signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

    return "$base64Header.$base64Payload.$base64Signature";
}

/**
 * التحقق من توكن JWT
 */
function verifyToken($token)
{
    $parts = explode('.', $token);
    if (count($parts) !== 3)
        return false;

    list($base64Header, $base64Payload, $base64Signature) = $parts;

    $signature = hash_hmac('sha256', "$base64Header.$base64Payload", JWT_SECRET, true);
    $expectedSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

    if ($base64Signature !== $expectedSignature)
        return false;

    $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $base64Payload)), true);

    if ($payload['exp'] < time())
        return false;

    return $payload;
}

/**
 * الحصول على التوكن من الـ Header
 */
function getBearerToken()
{
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';

    if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
        return $matches[1];
    }

    return null;
}

/**
 * التحقق من المصادقة
 */
function requireAuth()
{
    $token = getBearerToken();

    if (!$token) {
        errorResponse('التوكن غير موجود', 401);
    }

    $payload = verifyToken($token);

    if (!$payload) {
        errorResponse('التوكن غير صالح أو منتهي الصلاحية', 401);
    }

    return $payload;
}

/**
 * التحقق من الصلاحية
 */
function requireRole($allowedRoles)
{
    $payload = requireAuth();

    if (!is_array($allowedRoles)) {
        $allowedRoles = [$allowedRoles];
    }

    if (!in_array($payload['role'], $allowedRoles)) {
        errorResponse('ليس لديك صلاحية للوصول', 403);
    }

    return $payload;
}

// ===== إعداد CORS =====
function setupCORS()
{
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '*';

    if (in_array('*', ALLOWED_ORIGINS) || in_array($origin, ALLOWED_ORIGINS)) {
        header("Access-Control-Allow-Origin: $origin");
    }

    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Device-ID');
    header('Access-Control-Max-Age: 86400');

    // Handle preflight
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(204);
        exit;
    }
}

// تطبيق CORS على كل الطلبات
setupCORS();
