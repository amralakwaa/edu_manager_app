<?php
/**
 * ========================================
 * database.php - الاتصال بقاعدة البيانات
 * نظام إدارة التعليم / Education Management System
 * ========================================
 */

require_once __DIR__ . '/config.php';

/**
 * كلاس إدارة قاعدة البيانات
 */
class Database {
    private static $instance = null;
    private $pdo;
    
    /**
     * Constructor - إنشاء الاتصال
     */
    private function __construct() {
        try {
            $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
            
            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci"
            ];
            
            $this->pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
            
        } catch (PDOException $e) {
            if (APP_DEBUG) {
                errorResponse('خطأ في الاتصال بقاعدة البيانات: ' . $e->getMessage(), 500);
            } else {
                errorResponse('خطأ في الاتصال بقاعدة البيانات', 500);
            }
        }
    }
    
    /**
     * Singleton pattern
     */
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    /**
     * الحصول على PDO
     */
    public function getConnection() {
        return $this->pdo;
    }
    
    /**
     * تنفيذ استعلام SELECT
     */
    public function query($sql, $params = []) {
        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            return $stmt->fetchAll();
        } catch (PDOException $e) {
            if (APP_DEBUG) {
                throw $e;
            }
            return [];
        }
    }
    
    /**
     * تنفيذ استعلام SELECT وإرجاع صف واحد
     */
    public function queryOne($sql, $params = []) {
        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            return $stmt->fetch();
        } catch (PDOException $e) {
            if (APP_DEBUG) {
                throw $e;
            }
            return null;
        }
    }
    
    /**
     * تنفيذ استعلام INSERT/UPDATE/DELETE
     */
    public function execute($sql, $params = []) {
        try {
            $stmt = $this->pdo->prepare($sql);
            return $stmt->execute($params);
        } catch (PDOException $e) {
            if (APP_DEBUG) {
                throw $e;
            }
            return false;
        }
    }
    
    /**
     * إدراج سجل جديد
     */
    public function insert($table, $data) {
        $columns = implode(', ', array_keys($data));
        $placeholders = ':' . implode(', :', array_keys($data));
        
        $sql = "INSERT INTO $table ($columns) VALUES ($placeholders)";
        
        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($data);
            return $this->pdo->lastInsertId() ?: true;
        } catch (PDOException $e) {
            if (APP_DEBUG) {
                throw $e;
            }
            return false;
        }
    }
    
    /**
     * تحديث سجل
     */
    public function update($table, $data, $where, $whereParams = []) {
        $set = [];
        foreach (array_keys($data) as $column) {
            $set[] = "$column = :$column";
        }
        $setString = implode(', ', $set);
        
        $sql = "UPDATE $table SET $setString WHERE $where";
        
        try {
            $stmt = $this->pdo->prepare($sql);
            return $stmt->execute(array_merge($data, $whereParams));
        } catch (PDOException $e) {
            if (APP_DEBUG) {
                throw $e;
            }
            return false;
        }
    }
    
    /**
     * حذف سجل
     */
    public function delete($table, $where, $params = []) {
        $sql = "DELETE FROM $table WHERE $where";
        
        try {
            $stmt = $this->pdo->prepare($sql);
            return $stmt->execute($params);
        } catch (PDOException $e) {
            if (APP_DEBUG) {
                throw $e;
            }
            return false;
        }
    }
    
    /**
     * البحث في جدول
     */
    public function findById($table, $id) {
        return $this->queryOne("SELECT * FROM $table WHERE id = ?", [$id]);
    }
    
    /**
     * البحث في جدول بشرط
     */
    public function findBy($table, $column, $value) {
        return $this->query("SELECT * FROM $table WHERE $column = ?", [$value]);
    }
    
    /**
     * الحصول على كل السجلات
     */
    public function findAll($table, $orderBy = 'id', $limit = null) {
        $sql = "SELECT * FROM $table ORDER BY $orderBy";
        if ($limit) {
            $sql .= " LIMIT $limit";
        }
        return $this->query($sql);
    }
    
    /**
     * التحقق من وجود سجل
     */
    public function exists($table, $column, $value) {
        $result = $this->queryOne(
            "SELECT COUNT(*) as count FROM $table WHERE $column = ?",
            [$value]
        );
        return $result && $result['count'] > 0;
    }
    
    /**
     * عد السجلات
     */
    public function count($table, $where = '1=1', $params = []) {
        $result = $this->queryOne(
            "SELECT COUNT(*) as count FROM $table WHERE $where",
            $params
        );
        return $result ? (int)$result['count'] : 0;
    }
    
    /**
     * بدء معاملة
     */
    public function beginTransaction() {
        return $this->pdo->beginTransaction();
    }
    
    /**
     * تأكيد المعاملة
     */
    public function commit() {
        return $this->pdo->commit();
    }
    
    /**
     * التراجع عن المعاملة
     */
    public function rollback() {
        return $this->pdo->rollBack();
    }
}

// إنشاء متغير عام للوصول السهل
$db = Database::getInstance();
