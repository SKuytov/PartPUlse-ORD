-- Migration 001: Add urgency/priority enhancements and equipment linking
-- PartPulse World-Class Upgrade

-- Add equipment/machine linking to orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS equipment_id VARCHAR(100) DEFAULT NULL AFTER priority;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS equipment_name VARCHAR(255) DEFAULT NULL AFTER equipment_id;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS sla_status ENUM('on_track', 'at_risk', 'overdue') DEFAULT NULL AFTER expected_delivery_date;

-- Add department field to orders for better filtering
ALTER TABLE orders ADD COLUMN IF NOT EXISTS department VARCHAR(100) DEFAULT NULL AFTER building;

-- Create equipment registry table
CREATE TABLE IF NOT EXISTS equipment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_id VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    building VARCHAR(50),
    department VARCHAR(100),
    location VARCHAR(255),
    description TEXT,
    active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_building (building),
    INDEX idx_active (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
