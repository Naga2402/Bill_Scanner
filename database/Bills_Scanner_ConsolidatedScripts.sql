-- ============================================
-- Bill Scanner App - Consolidated Database Scripts
-- ============================================
-- This file contains all database setup scripts in the correct order
-- Run this script after creating the database with 01_create_database.sql
--
-- Usage:
--   psql -U postgres -d bill_scanner_db -f Bills_Scanner_ConsolidatedScripts.sql
--
-- Last Updated: 2025-11-20
-- Version: 1.1
-- ============================================

-- ============================================
-- SECTION 1: EXTENSIONS
-- ============================================
-- Date: 2025-11-19
-- Reason: Required for UUID generation and password hashing
-- Status: Initial implementation
-- ============================================

-- Ensure UUID extension is enabled (required for uuid_generate_v4())
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Ensure pgcrypto extension is enabled (required for password hashing)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Verify extensions are installed
SELECT 
    extname as "Extension Name",
    extversion as "Version"
FROM pg_extension 
WHERE extname IN ('uuid-ossp', 'pgcrypto');

-- Test UUID generation
SELECT uuid_generate_v4() as "Test UUID Generation";

COMMENT ON EXTENSION "uuid-ossp" IS 'UUID generation functions';
COMMENT ON EXTENSION "pgcrypto" IS 'Cryptographic functions for password hashing';

-- ============================================
-- SECTION 2: TABLES AND BASIC INDEXES
-- ============================================
-- Date: 2025-11-19
-- Reason: Core database schema for Bill Scanner app
-- Status: Initial implementation
-- ============================================

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_created_at ON users(created_at);

COMMENT ON TABLE users IS 'User accounts for the Bill Scanner app';
COMMENT ON COLUMN users.password_hash IS 'Bcrypt hashed password';
COMMENT ON COLUMN users.username IS 'Unique username for login (alternative to email)';

-- ============================================
-- USER_SETTINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS user_settings (
    setting_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    currency VARCHAR(10) DEFAULT 'USD',
    appearance_mode VARCHAR(20) DEFAULT 'system', -- 'light', 'dark', 'system'
    default_category VARCHAR(100) DEFAULT 'Uncategorized',
    push_notifications_enabled BOOLEAN DEFAULT TRUE,
    email_notifications_enabled BOOLEAN DEFAULT FALSE,
    bill_reminders_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);

COMMENT ON TABLE user_settings IS 'User preferences and settings';

-- ============================================
-- CATEGORIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS categories (
    category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7), -- Hex color code
    icon VARCHAR(50), -- Icon name
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, name)
);

CREATE INDEX idx_categories_user_id ON categories(user_id);

COMMENT ON TABLE categories IS 'Bill categories (can be user-specific or default)';

-- Insert default categories
INSERT INTO categories (user_id, name, color, icon, is_default) VALUES
(NULL, 'Groceries', '#4CAF50', 'shopping_cart', TRUE),
(NULL, 'Utilities', '#9C27B0', 'home', TRUE),
(NULL, 'Food', '#FF9800', 'restaurant', TRUE),
(NULL, 'Shopping', '#2196F3', 'shopping_bag', TRUE),
(NULL, 'Transport', '#F44336', 'local_gas_station', TRUE),
(NULL, 'Healthcare', '#E91E63', 'local_hospital', TRUE),
(NULL, 'Entertainment', '#00BCD4', 'movie', TRUE),
(NULL, 'Uncategorized', '#9E9E9E', 'label', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- BILLS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS bills (
    bill_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    vendor_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    bill_date DATE NOT NULL,
    category_id UUID REFERENCES categories(category_id) ON DELETE SET NULL,
    description TEXT,
    image_path VARCHAR(500), -- Path to scanned bill image
    ocr_text TEXT, -- Extracted text from OCR
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_period VARCHAR(20), -- 'monthly', 'weekly', 'yearly'
    due_date DATE,
    is_paid BOOLEAN DEFAULT TRUE,
    payment_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_bills_user_id ON bills(user_id);
CREATE INDEX idx_bills_bill_date ON bills(bill_date);
CREATE INDEX idx_bills_category_id ON bills(category_id);
CREATE INDEX idx_bills_vendor_name ON bills(vendor_name);
CREATE INDEX idx_bills_user_date ON bills(user_id, bill_date DESC);

COMMENT ON TABLE bills IS 'Scanned bills and expenses';
COMMENT ON COLUMN bills.ocr_text IS 'Raw text extracted from bill image via OCR';

-- ============================================
-- BILL_IMAGES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS bill_images (
    image_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bill_id UUID NOT NULL REFERENCES bills(bill_id) ON DELETE CASCADE,
    image_path VARCHAR(500) NOT NULL,
    image_type VARCHAR(20) DEFAULT 'original', -- 'original', 'processed', 'thumbnail'
    file_size BIGINT, -- Size in bytes
    width INTEGER,
    height INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_bill_images_bill_id ON bill_images(bill_id);

COMMENT ON TABLE bill_images IS 'Bill image files (original, processed, thumbnails)';

-- ============================================
-- EXPORT_HISTORY TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS export_history (
    export_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    export_type VARCHAR(20) NOT NULL, -- 'pdf', 'csv', 'excel'
    file_path VARCHAR(500),
    date_range_start DATE,
    date_range_end DATE,
    filters_applied JSONB, -- Store filter criteria as JSON
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_export_history_user_id ON export_history(user_id);
CREATE INDEX idx_export_history_created_at ON export_history(created_at);

COMMENT ON TABLE export_history IS 'History of exported reports';

-- ============================================
-- PASSWORD_RESET_TOKENS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    token_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_password_reset_tokens_token ON password_reset_tokens(token);
CREATE INDEX idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);

COMMENT ON TABLE password_reset_tokens IS 'Password reset tokens for forgot password functionality';

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50), -- 'bill_reminder', 'spending_alert', 'system'
    is_read BOOLEAN DEFAULT FALSE,
    related_bill_id UUID REFERENCES bills(bill_id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

COMMENT ON TABLE notifications IS 'User notifications and alerts';

-- ============================================
-- UPDATE TIMESTAMPS TRIGGER FUNCTION
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables with updated_at column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bills_updated_at BEFORE UPDATE ON bills
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SECTION 3: ADDITIONAL PERFORMANCE INDEXES
-- ============================================
-- Date: 2025-11-19
-- Reason: Performance optimization for common queries
-- Status: Initial implementation
-- Note: Fixed immutable function issue with date-based predicates
-- ============================================

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_bills_user_category_date 
    ON bills(user_id, category_id, bill_date DESC);

CREATE INDEX IF NOT EXISTS idx_bills_user_vendor 
    ON bills(user_id, vendor_name);

CREATE INDEX IF NOT EXISTS idx_bills_recurring 
    ON bills(user_id, is_recurring) WHERE is_recurring = TRUE;

CREATE INDEX IF NOT EXISTS idx_bills_unpaid 
    ON bills(user_id, is_paid, due_date) WHERE is_paid = FALSE;

-- Full text search index for OCR text
-- Note: Only create if ocr_text column has data, otherwise it may cause issues
CREATE INDEX IF NOT EXISTS idx_bills_ocr_text_search 
    ON bills USING gin(to_tsvector('english', ocr_text))
    WHERE ocr_text IS NOT NULL AND ocr_text != '';

-- Index for recent bills (optimized for queries on recent data)
-- Note: We use a regular index instead of a date-based predicate
-- The query optimizer will still use this effectively for date range queries
CREATE INDEX IF NOT EXISTS idx_bills_user_date_recent 
    ON bills(user_id, bill_date DESC);

COMMENT ON INDEX idx_bills_ocr_text_search IS 'Full text search index for OCR text content';
COMMENT ON INDEX idx_bills_user_date_recent IS 'Index for efficient date range queries, sorted by most recent first';

-- ============================================
-- SECTION 4: SAMPLE DATA (OPTIONAL)
-- ============================================
-- Date: 2025-11-19
-- Reason: Insert sample data for testing and development
-- Status: Initial implementation
-- Note: This section can be commented out for production
-- ============================================

-- Sample User (password: 'demo123' hashed with bcrypt)
-- Use: SELECT crypt('demo123', gen_salt('bf')); to generate new hashes
INSERT INTO users (user_id, email, password_hash, full_name, email_verified, is_active)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'demo@billscanner.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', -- password: demo123
    'Demo User',
    TRUE,
    TRUE
) ON CONFLICT (email) DO NOTHING;

-- Sample User Settings
INSERT INTO user_settings (user_id, currency, appearance_mode, default_category, push_notifications_enabled)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'USD',
    'system',
    'Uncategorized',
    TRUE
) ON CONFLICT (user_id) DO NOTHING;

-- Sample Bills
INSERT INTO bills (user_id, vendor_name, amount, bill_date, category_id, description, is_paid)
SELECT 
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    vendor_name,
    amount,
    bill_date,
    (SELECT category_id FROM categories WHERE name = category_name LIMIT 1),
    description,
    TRUE
FROM (VALUES
    ('Amazon', 128.70, '2023-10-28'::DATE, 'Shopping', 'Online purchase'),
    ('Starbucks', 12.50, '2023-10-26'::DATE, 'Food', 'Coffee'),
    ('Shell Gas', 45.30, '2023-10-25'::DATE, 'Transport', 'Gas station'),
    ('AT&T Internet', 85.00, '2023-10-24'::DATE, 'Utilities', 'Monthly internet bill'),
    ('The Cheesecake Factory', 92.15, '2023-10-22'::DATE, 'Food', 'Dinner')
) AS sample(vendor_name, amount, bill_date, category_name, description)
ON CONFLICT DO NOTHING;

-- ============================================
-- TEMPLATE FOR FUTURE ADDITIONS
-- ============================================
-- When adding new scripts, use this template:
--
-- -- ============================================
-- -- SECTION X: [SECTION NAME]
-- -- ============================================
-- -- Date: YYYY-MM-DD
-- -- Reason: [Brief description of why this was added]
-- -- Status: [Initial implementation / Update / Fix / Enhancement]
-- -- Related Issue/Ticket: [If applicable]
-- -- ============================================
--
-- [Your SQL code here]
--
-- ============================================
-- END OF CONSOLIDATED SCRIPTS
-- ============================================

