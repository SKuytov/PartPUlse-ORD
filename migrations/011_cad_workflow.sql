-- Migration 011: CAD Documentation Workflow

ALTER TABLE orders ADD COLUMN IF NOT EXISTS requires_cad BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cad_assigned_to_user_id INT NULL;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cad_status ENUM('not_started','in_progress','review_needed','approved','delivered') NULL;

CREATE TABLE IF NOT EXISTS cad_log_entries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  user_id INT NOT NULL,
  entry_type ENUM('progress','question','reply','status_change','file_ref') NOT NULL,
  content TEXT NOT NULL,
  addressed_to_user_id INT NULL,
  parent_entry_id INT NULL,
  is_answered BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
