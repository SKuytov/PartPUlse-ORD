-- Migration 003: Recurring Orders
-- PartPulse World-Class Upgrade

ALTER TABLE orders ADD COLUMN IF NOT EXISTS is_recurring TINYINT(1) DEFAULT 0 AFTER notes;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS recurring_frequency ENUM('weekly', 'biweekly', 'monthly', 'quarterly') DEFAULT NULL AFTER is_recurring;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS recurring_next_date DATE DEFAULT NULL AFTER recurring_frequency;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS recurring_parent_id INT DEFAULT NULL AFTER recurring_next_date;

-- Index for recurring order queries
ALTER TABLE orders ADD INDEX IF NOT EXISTS idx_recurring (is_recurring, recurring_next_date);
ALTER TABLE orders ADD INDEX IF NOT EXISTS idx_recurring_parent (recurring_parent_id);
