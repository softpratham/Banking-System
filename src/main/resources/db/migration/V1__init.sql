-- V1__init.sql
-- Core schema for Banking System

SET SQL_MODE = 'STRICT_TRANS_TABLES';
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS customers (
  id CHAR(36) PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(30) UNIQUE,
  kyc_status VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS accounts (
  id CHAR(36) PRIMARY KEY,
  customer_id CHAR(36) NOT NULL,
  account_number VARCHAR(32) UNIQUE NOT NULL,
  account_type VARCHAR(32) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (customer_id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ledger_entries (
  id CHAR(36) PRIMARY KEY,
  account_id CHAR(36) NOT NULL,
  tx_id CHAR(36) NOT NULL,
  amount DECIMAL(18,2) NOT NULL,
  side ENUM('DEBIT','CREDIT') NOT NULL,
  balance_snapshot DECIMAL(18,2),
  narration VARCHAR(512),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (account_id),
  FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS transfers (
  id CHAR(36) PRIMARY KEY,
  idempotency_key VARCHAR(255) UNIQUE,
  from_account CHAR(36) NOT NULL,
  to_account CHAR(36),
  amount DECIMAL(18,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  status ENUM('PENDING','SUCCESS','FAILED') NOT NULL DEFAULT 'PENDING',
  error_msg VARCHAR(512),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (from_account),
  INDEX (to_account),
  FOREIGN KEY (from_account) REFERENCES accounts(id),
  FOREIGN KEY (to_account) REFERENCES accounts(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS idempotency_keys (
  key_hash VARCHAR(128) PRIMARY KEY,
  response JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS outbox (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  aggregate_type VARCHAR(50),
  aggregate_id CHAR(36),
  event_type VARCHAR(100),
  payload JSON,
  processed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (processed)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id CHAR(36),
  action VARCHAR(100),
  entity_type VARCHAR(100),
  entity_id CHAR(36),
  details JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS admins (
  id CHAR(36) PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS loans (
  id CHAR(36) PRIMARY KEY,
  customer_id CHAR(36) NOT NULL,
  principal DECIMAL(18,2) NOT NULL,
  outstanding DECIMAL(18,2) NOT NULL,
  interest_rate DECIMAL(5,3),
  term_months INT,
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (customer_id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS credit_cards (
  id CHAR(36) PRIMARY KEY,
  customer_id CHAR(36) NOT NULL,
  encrypted_pan VARCHAR(1024),
  pan_last4 VARCHAR(4),
  pin_hash VARCHAR(255),
  status VARCHAR(32) DEFAULT 'ACTIVE',
  limit_amount DECIMAL(18,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (customer_id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;
