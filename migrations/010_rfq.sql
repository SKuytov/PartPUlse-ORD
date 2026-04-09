-- Migration 010: RFQ (Request for Quote) System

CREATE TABLE IF NOT EXISTS rfqs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rfq_number VARCHAR(50) NOT NULL UNIQUE,
  supplier_id INT NULL,
  supplier_name VARCHAR(255) NOT NULL,
  created_by_user_id INT NOT NULL,
  status ENUM('draft','sent','response_received','accepted','rejected') NOT NULL DEFAULT 'draft',
  notes TEXT,
  sent_at TIMESTAMP NULL,
  response_due_date DATE NULL,
  response_notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rfq_order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rfq_id INT NOT NULL,
  order_id INT NOT NULL,
  FOREIGN KEY (rfq_id) REFERENCES rfqs(id) ON DELETE CASCADE,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Add supplier assignment fields to orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS assigned_supplier_id INT NULL;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS assigned_supplier_name VARCHAR(255) NULL;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS rfq_id INT NULL;
