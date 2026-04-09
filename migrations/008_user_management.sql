-- Migration 008: Enhanced User Management
-- Adds multi-role support, invite tokens, and ensures active column exists

-- roles JSON column for multi-role support (e.g. ["procurement","cad_designer","admin"])
ALTER TABLE users ADD COLUMN IF NOT EXISTS roles JSON;

-- Invite token support
ALTER TABLE users ADD COLUMN IF NOT EXISTS invite_token VARCHAR(64);
ALTER TABLE users ADD COLUMN IF NOT EXISTS invite_expires_at TIMESTAMP NULL;

-- Last login tracking
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP NULL;

-- Ensure active column exists (may already exist)
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS active BOOLEAN NOT NULL DEFAULT TRUE;
-- Note: 'active' column already exists in the users table from the original schema
