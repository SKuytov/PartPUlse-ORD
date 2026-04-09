-- Migration 007: Super Admin Role
-- Adds is_super_admin flag to users table

ALTER TABLE users ADD COLUMN IF NOT EXISTS is_super_admin BOOLEAN NOT NULL DEFAULT FALSE;

-- App-level enforcement ensures only one super admin exists.
-- The first user marked as super_admin becomes the sole super admin.
