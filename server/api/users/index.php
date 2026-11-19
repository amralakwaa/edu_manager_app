<?php
/**
 * ========================================
 * index.php - قائمة المستخدمين
 * نظام إدارة التعليم / Education Management System
 * ========================================
 */

require_once __DIR__ . '/../database.php';

// التحقق من المصادقة والصلاحية
$authUser = requireRole(['admin']);

// الحصول على معاملات الاستعلام
$role = $_GET['role'] ?? null;
$status = $_GET['status'] ?? null;
$search = $_GET['search'] ?? null;
$page = max(1, intval($_GET['page'] ?? 1));
$limit = min(100, max(1, intval($_GET['limit'] ?? 20)));
$offset = ($page - 1) * $limit;

// بناء الاستعلام
$where = ['1=1'];
$params = [];

if ($role) {
    $where[] = 'role = ?';
    $params[] = $role;
}

if ($status !== null) {
    $where[] = 'is_active = ?';
    $params[] = $status === 'active' ? 1 : 0;
}

if ($search) {
    $where[] = '(name LIKE ? OR email LIKE ?)';
    $params[] = "%$search%";
    $params[] = "%$search%";
}

$whereClause = implode(' AND ', $where);

// الحصول على إجمالي السجلات
$totalResult = $db->queryOne(
    "SELECT COUNT(*) as total FROM users WHERE $whereClause",
    $params
);
$total = $totalResult['total'];

// الحصول على المستخدمين
$users = $db->query(
    "SELECT id, name, email, role, phone, avatar_url, is_active, 
            last_login, created_at, updated_at 
     FROM users 
     WHERE $whereClause 
     ORDER BY created_at DESC 
     LIMIT $limit OFFSET $offset",
    $params
);

// إرجاع الاستجابة
successResponse([
    'users' => $users,
    'pagination' => [
        'current_page' => $page,
        'per_page' => $limit,
        'total' => (int) $total,
        'total_pages' => ceil($total / $limit)
    ]
]);
