-- Migration 009: Order Claiming & Locking
-- Adds claim tracking and help request fields to orders

ALTER TABLE orders ADD COLUMN IF NOT EXISTS claimed_by_user_id INT NULL;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS claimed_at TIMESTAMP NULL;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS claim_auto_release_hours INT NOT NULL DEFAULT 4;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS help_requested BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS help_request_note TEXT NULL;
