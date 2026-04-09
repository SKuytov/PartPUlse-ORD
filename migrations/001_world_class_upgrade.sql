-- PartPulse Orders - World Class Upgrade Migration
-- Version: 1.0
-- Date: 2026-04-09
-- Description: Adds tables and columns for notifications, saved filters,
--              equipment tracking, comments, user preferences, and budgets

-- ============================================
-- 1. NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('status_change', 'approval_needed', 'approval_result', 'overdue', 'delivery_today', 'comment', 'assignment', 'system') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    related_order_id INT DEFAULT NULL,
    related_approval_id INT DEFAULT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_created (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 2. SAVED FILTERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS saved_filters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    filter_config JSON NOT NULL,
    is_default TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 3. ORDER COMMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS order_comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_order (order_id),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 4. USER PREFERENCES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS user_preferences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    table_density ENUM('compact', 'comfortable', 'spacious') DEFAULT 'comfortable',
    visible_columns JSON DEFAULT NULL,
    default_filter_id INT DEFAULT NULL,
    notifications_enabled TINYINT(1) DEFAULT 1,
    notify_status_change TINYINT(1) DEFAULT 1,
    notify_approval TINYINT(1) DEFAULT 1,
    notify_overdue TINYINT(1) DEFAULT 1,
    notify_delivery TINYINT(1) DEFAULT 1,
    notify_comments TINYINT(1) DEFAULT 1,
    theme VARCHAR(20) DEFAULT 'dark',
    language VARCHAR(5) DEFAULT 'en',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 5. EQUIPMENT / MACHINE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS equipment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    building_code VARCHAR(50),
    department VARCHAR(100),
    manufacturer VARCHAR(200),
    model VARCHAR(200),
    serial_number VARCHAR(200),
    install_date DATE,
    status ENUM('operational', 'down', 'maintenance', 'retired') DEFAULT 'operational',
    criticality ENUM('critical', 'high', 'medium', 'low') DEFAULT 'medium',
    notes TEXT,
    active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_building (building_code),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 6. ADD EQUIPMENT COLUMNS TO ORDERS
-- ============================================
ALTER TABLE orders ADD COLUMN IF NOT EXISTS equipment_id INT DEFAULT NULL AFTER category;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS machine_down TINYINT(1) DEFAULT 0 AFTER equipment_id;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS estimated_downtime_hours DECIMAL(10,2) DEFAULT NULL AFTER machine_down;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS pinned TINYINT(1) DEFAULT 0 AFTER estimated_downtime_hours;

-- ============================================
-- 7. DEPARTMENT BUDGETS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS department_budgets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    building_code VARCHAR(50) NOT NULL,
    cost_center_id INT,
    fiscal_year INT NOT NULL,
    fiscal_quarter TINYINT,
    budget_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    spent_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_budget (building_code, cost_center_id, fiscal_year, fiscal_quarter),
    INDEX idx_year (fiscal_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 8. ADD INVOICE STATUS COLUMNS
-- ============================================
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS due_date DATE DEFAULT NULL AFTER invoice_date;
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS payment_date DATE DEFAULT NULL AFTER due_date;
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS department VARCHAR(100) DEFAULT NULL AFTER payment_date;
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS cost_center_id INT DEFAULT NULL AFTER department;

-- ============================================
-- 9. PINNED ORDERS INDEX
-- ============================================
ALTER TABLE orders ADD INDEX IF NOT EXISTS idx_pinned (pinned);

-- ============================================
-- 10. SEED SAMPLE EQUIPMENT DATA
-- ============================================
INSERT IGNORE INTO equipment (code, name, building_code, status, criticality) VALUES
('EQ-001', 'Main Production Line A', 'CT', 'operational', 'critical'),
('EQ-002', 'Packaging Machine B', 'CT', 'operational', 'high'),
('EQ-003', 'HVAC System', 'CT', 'operational', 'medium'),
('EQ-004', 'Conveyor Belt C', 'CT', 'operational', 'high'),
('EQ-005', 'Boiler Room Unit', 'CT', 'maintenance', 'critical');
