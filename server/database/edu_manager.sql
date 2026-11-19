-- ========================================
-- edu_manager.sql - قاعدة بيانات نظام إدارة التعليم
-- Education Management System Database
-- ========================================
-- 
-- تعليمات التثبيت:
-- 1. افتح XAMPP وشغل Apache و MySQL
-- 2. افتح phpMyAdmin: http://localhost/phpmyadmin
-- 3. أنشئ قاعدة بيانات جديدة باسم: edu_manager
-- 4. اختر قاعدة البيانات واضغط على "Import"
-- 5. اختر هذا الملف واضغط "Go"
-- ========================================

-- إنشاء قاعدة البيانات إذا لم تكن موجودة
CREATE DATABASE IF NOT EXISTS edu_manager 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE edu_manager;

-- ========================================
-- جدول المستخدمين / Users Table
-- ========================================
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'teacher', 'student') NOT NULL DEFAULT 'student',
    phone VARCHAR(20),
    avatar_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    device_id VARCHAR(100),
    last_login DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_device_id (device_id)
) ENGINE=InnoDB;

-- ========================================
-- جدول الطلاب / Students Table
-- ========================================
CREATE TABLE IF NOT EXISTS students (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    student_number VARCHAR(20) UNIQUE NOT NULL,
    grade VARCHAR(20) NOT NULL,
    section VARCHAR(10),
    date_of_birth DATE,
    gender ENUM('male', 'female'),
    guardian_name VARCHAR(100),
    guardian_phone VARCHAR(20),
    address TEXT,
    gpa DECIMAL(3,2) DEFAULT 0.00,
    status ENUM('active', 'inactive', 'graduated', 'suspended') DEFAULT 'active',
    enrollment_date DATE NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_student_number (student_number),
    INDEX idx_grade (grade),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- ========================================
-- جدول المعلمين / Teachers Table
-- ========================================
CREATE TABLE IF NOT EXISTS teachers (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    employee_number VARCHAR(20) UNIQUE NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    qualification VARCHAR(100),
    experience_years INT DEFAULT 0,
    status ENUM('active', 'inactive', 'terminated') DEFAULT 'active',
    hire_date DATE NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_employee_number (employee_number),
    INDEX idx_specialization (specialization)
) ENGINE=InnoDB;

-- ========================================
-- جدول المواد الدراسية / Materials Table
-- ========================================
CREATE TABLE IF NOT EXISTS materials (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    teacher_id VARCHAR(36),
    grade VARCHAR(20) NOT NULL,
    semester VARCHAR(20) NOT NULL,
    credit_hours INT DEFAULT 3,
    total_marks DECIMAL(5,2) DEFAULT 100.00,
    passing_marks DECIMAL(5,2) DEFAULT 50.00,
    days JSON,
    start_time TIME,
    end_time TIME,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL,
    INDEX idx_code (code),
    INDEX idx_grade (grade),
    INDEX idx_teacher (teacher_id)
) ENGINE=InnoDB;

-- ========================================
-- جدول تسجيل الطلاب في المواد / Enrollments Table
-- ========================================
CREATE TABLE IF NOT EXISTS enrollments (
    id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(36) NOT NULL,
    material_id VARCHAR(36) NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('enrolled', 'withdrawn', 'completed') DEFAULT 'enrolled',
    
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES materials(id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, material_id)
) ENGINE=InnoDB;

-- ========================================
-- جدول الواجبات / Assignments Table
-- ========================================
CREATE TABLE IF NOT EXISTS assignments (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    material_id VARCHAR(36) NOT NULL,
    teacher_id VARCHAR(36) NOT NULL,
    grade VARCHAR(20) NOT NULL,
    start_date DATETIME NOT NULL,
    due_date DATETIME NOT NULL,
    total_marks DECIMAL(5,2) DEFAULT 100.00,
    status ENUM('draft', 'published', 'closed') DEFAULT 'published',
    attachments JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (material_id) REFERENCES materials(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
    INDEX idx_material (material_id),
    INDEX idx_due_date (due_date),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- ========================================
-- جدول تسليم الواجبات / Submissions Table
-- ========================================
CREATE TABLE IF NOT EXISTS submissions (
    id VARCHAR(36) PRIMARY KEY,
    assignment_id VARCHAR(36) NOT NULL,
    student_id VARCHAR(36) NOT NULL,
    content TEXT,
    attachments JSON,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    score DECIMAL(5,2),
    feedback TEXT,
    status ENUM('submitted', 'late', 'graded') DEFAULT 'submitted',
    graded_at DATETIME,
    
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE KEY unique_submission (assignment_id, student_id)
) ENGINE=InnoDB;

-- ========================================
-- جدول الدرجات / Grades Table
-- ========================================
CREATE TABLE IF NOT EXISTS grades (
    id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(36) NOT NULL,
    material_id VARCHAR(36) NOT NULL,
    teacher_id VARCHAR(36) NOT NULL,
    grade_type ENUM('midterm', 'final', 'quiz', 'assignment', 'project', 'participation') NOT NULL,
    title VARCHAR(100) NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    total_marks DECIMAL(5,2) NOT NULL,
    percentage DECIMAL(5,2) GENERATED ALWAYS AS (score / total_marks * 100) STORED,
    notes TEXT,
    graded_at DATETIME NOT NULL,
    semester VARCHAR(20) NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES materials(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
    INDEX idx_student (student_id),
    INDEX idx_material (material_id),
    INDEX idx_type (grade_type)
) ENGINE=InnoDB;

-- ========================================
-- جدول الحضور / Attendance Table
-- ========================================
CREATE TABLE IF NOT EXISTS attendance (
    id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(36) NOT NULL,
    material_id VARCHAR(36) NOT NULL,
    teacher_id VARCHAR(36) NOT NULL,
    date DATE NOT NULL,
    status ENUM('present', 'absent', 'late', 'excused') NOT NULL,
    check_in_time TIME,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES materials(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
    UNIQUE KEY unique_attendance (student_id, material_id, date),
    INDEX idx_date (date),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- ========================================
-- جدول التوكنات / Tokens Table
-- ========================================
CREATE TABLE IF NOT EXISTS tokens (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    token VARCHAR(500) NOT NULL,
    device_id VARCHAR(100),
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token(255)),
    INDEX idx_user (user_id)
) ENGINE=InnoDB;

-- ========================================
-- جدول سجل المزامنة / Sync Log Table
-- ========================================
CREATE TABLE IF NOT EXISTS sync_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    device_id VARCHAR(100) NOT NULL,
    user_id VARCHAR(36),
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id VARCHAR(36),
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_device (device_id),
    INDEX idx_synced (synced_at)
) ENGINE=InnoDB;

-- ========================================
-- إدخال بيانات تجريبية / Sample Data
-- ========================================

-- Admin user (password: admin123)
INSERT INTO users (id, name, email, password, role, is_active) VALUES
('admin-001', 'مدير النظام', 'admin@edumanager.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', TRUE);

-- Teacher users (password: teacher123)
INSERT INTO users (id, name, email, password, role, phone, is_active) VALUES
('teacher-001', 'أحمد محمد', 'ahmed@edumanager.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'teacher', '0501234567', TRUE),
('teacher-002', 'سارة علي', 'sara@edumanager.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'teacher', '0507654321', TRUE);

-- Student users (password: student123)
INSERT INTO users (id, name, email, password, role, phone, is_active) VALUES
('student-001', 'محمد خالد', 'mohammed@student.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student', '0551234567', TRUE),
('student-002', 'فاطمة أحمد', 'fatima@student.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student', '0557654321', TRUE),
('student-003', 'عبدالله سعيد', 'abdullah@student.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student', '0559876543', TRUE);

-- Teachers data
INSERT INTO teachers (id, user_id, employee_number, specialization, qualification, experience_years, hire_date) VALUES
('t-001', 'teacher-001', 'EMP001', 'الرياضيات', 'ماجستير', 10, '2015-09-01'),
('t-002', 'teacher-002', 'EMP002', 'اللغة العربية', 'بكالوريوس', 5, '2019-09-01');

-- Students data
INSERT INTO students (id, user_id, student_number, grade, section, date_of_birth, gender, enrollment_date) VALUES
('s-001', 'student-001', 'STU2024001', 'الصف العاشر', 'أ', '2008-05-15', 'male', '2024-09-01'),
('s-002', 'student-002', 'STU2024002', 'الصف العاشر', 'أ', '2008-08-20', 'female', '2024-09-01'),
('s-003', 'student-003', 'STU2024003', 'الصف العاشر', 'ب', '2008-03-10', 'male', '2024-09-01');

-- Materials data
INSERT INTO materials (id, name, code, description, teacher_id, grade, semester, credit_hours) VALUES
('m-001', 'الرياضيات', 'MATH101', 'مادة الرياضيات للصف العاشر', 't-001', 'الصف العاشر', 'الأول', 4),
('m-002', 'اللغة العربية', 'ARAB101', 'مادة اللغة العربية للصف العاشر', 't-002', 'الصف العاشر', 'الأول', 4);

-- Enrollments
INSERT INTO enrollments (id, student_id, material_id) VALUES
('e-001', 's-001', 'm-001'),
('e-002', 's-001', 'm-002'),
('e-003', 's-002', 'm-001'),
('e-004', 's-002', 'm-002'),
('e-005', 's-003', 'm-001'),
('e-006', 's-003', 'm-002');

-- Sample assignment
INSERT INTO assignments (id, title, description, material_id, teacher_id, grade, start_date, due_date, total_marks) VALUES
('a-001', 'واجب الجبر', 'حل تمارين الفصل الأول', 'm-001', 't-001', 'الصف العاشر', NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), 20);

-- ========================================
-- عرض ملخص / Summary View
-- ========================================
CREATE OR REPLACE VIEW v_dashboard_stats AS
SELECT 
    (SELECT COUNT(*) FROM users WHERE role = 'student' AND is_active = TRUE) as total_students,
    (SELECT COUNT(*) FROM users WHERE role = 'teacher' AND is_active = TRUE) as total_teachers,
    (SELECT COUNT(*) FROM materials WHERE status = 'active') as total_materials,
    (SELECT COUNT(*) FROM assignments WHERE status = 'published') as active_assignments,
    (SELECT COALESCE(AVG(percentage), 0) FROM grades) as average_grade,
    (SELECT COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM attendance), 0) FROM attendance WHERE status = 'present') as attendance_rate;

COMMIT;

-- ========================================
-- ملاحظة هامة / Important Note
-- ========================================
-- كلمة المرور الافتراضية لجميع المستخدمين: password
-- Default password for all users: password
-- ========================================
