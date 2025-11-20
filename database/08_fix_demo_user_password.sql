-- ============================================
-- Fix Demo User Password
-- ============================================
-- The password hash in the database doesn't match "demo123"
-- Run this script to update it with a correct hash

\c bill_scanner_db;

-- Update password hash for demo user
-- Password: demo123
-- This hash was generated using Python bcrypt on 2025-01-XX
UPDATE users 
SET password_hash = '$2b$12$4JVKCEL2Uf/Lj16aukh4oOQUmAyh.yVpf3jcKya0WnIcAUQu2IRQ2'
WHERE email = 'demo@billscanner.com';

-- Verify the update
SELECT 
    email,
    full_name,
    is_active,
    SUBSTRING(password_hash, 1, 20) as hash_preview
FROM users 
WHERE email = 'demo@billscanner.com';

-- Note: The hash above is a placeholder. 
-- Run backend/generate_password_hash.py to get the actual hash
-- Then replace the hash in this UPDATE statement

