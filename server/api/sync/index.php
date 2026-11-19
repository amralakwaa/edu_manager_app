<?php
/**
 * ========================================
 * sync/index.php - نقطة نهاية المزامنة
 * نظام إدارة التعليم / Education Management System
 * ========================================
 */

require_once '../config.php';

// التحقق من المصادقة (اختياري حسب طبيعة المزامنة)
// $user = requireAuth();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    handleSyncUpload();
} else if ($method === 'GET') {
    handleSyncDownload();
} else {
    errorResponse('طريقة طلب غير صالحة', 405);
}

/**
 * استلام البيانات من التطبيق ومزامنتها مع القاعدة
 */
function handleSyncUpload()
{
    $input = getJsonInput();
    $data = $input['data'] ?? [];
    $deviceId = $_SERVER['HTTP_X_DEVICE_ID'] ?? 'unknown';
    $db = null;

    if (empty($data)) {
        errorResponse('لا توجد بيانات للمزامنة');
    }

    try {
        $db = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET, DB_USER, DB_PASS);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        $results = [
            'synced_count' => 0,
            'errors' => []
        ];

        $db->beginTransaction();

        foreach ($data as $item) {
            $table = $item['table'] ?? '';
            $action = $item['action'] ?? 'save';
            $payload = $item['payload'] ?? [];
            $recordId = $payload['id'] ?? null;

            if (!$table || !$recordId)
                continue;

            // تنفيذ المزامنة حسب الجدول
            try {
                syncRecord($db, $table, $payload);

                // تسجيل في سجل المزامنة
                $stmt = $db->prepare("INSERT INTO sync_log (device_id, action, table_name, record_id) VALUES (?, ?, ?, ?)");
                $stmt->execute([$deviceId, $action, $table, $recordId]);

                $results['synced_count']++;
            } catch (Exception $e) {
                $results['errors'][] = [
                    'id' => $recordId,
                    'table' => $table,
                    'error' => $e->getMessage()
                ];
            }
        }

        $db->commit();
        successResponse($results, 'تمت عملية المزامنة بنجاح');

    } catch (PDOException $e) {
        if ($db)
            $db->rollBack();
        errorResponse('خطأ في قاعدة البيانات: ' . $e->getMessage(), 500);
    }
}

/**
 * إرسال التحديثات من السيرفر للتطبيق
 */
function handleSyncDownload()
{
    $lastSync = $_GET['last_sync'] ?? '2000-01-01 00:00:00';

    try {
        $db = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET, DB_USER, DB_PASS);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        $updates = [
            'students' => fetchUpdates($db, 'students', $lastSync),
            'teachers' => fetchUpdates($db, 'teachers', $lastSync),
            'materials' => fetchUpdates($db, 'materials', $lastSync),
            'assignments' => fetchUpdates($db, 'assignments', $lastSync),
            'server_time' => date('Y-m-d H:i:s')
        ];

        successResponse($updates);

    } catch (PDOException $e) {
        errorResponse('خطأ في قاعدة البيانات: ' . $e->getMessage(), 500);
    }
}

/**
 * مزامنة سجل واحد (Insert or Update)
 */
function syncRecord($db, $table, $payload)
{
    $columns = array_keys($payload);
    $placeholders = array_fill(0, count($columns), '?');

    $updateParts = [];
    foreach ($columns as $col) {
        $updateParts[] = "$col = VALUES($col)";
    }

    $sql = "INSERT INTO $table (" . implode(',', $columns) . ") 
            VALUES (" . implode(',', $placeholders) . ") 
            ON DUPLICATE KEY UPDATE " . implode(',', $updateParts);

    $stmt = $db->prepare($sql);
    $stmt->execute(array_values($payload));
}

/**
 * جلب التحديثات بعد تاريخ معين
 */
function fetchUpdates($db, $table, $lastSync)
{
    try {
        $stmt = $db->prepare("SELECT * FROM $table WHERE updated_at > ?");
        $stmt->execute([$lastSync]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        return [];
    }
}
