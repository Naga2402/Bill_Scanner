-- ============================================
-- Add username column to users table
-- ============================================
-- Date: 2025-11-20
-- Reason: Support login with email or username
-- Status: Initial implementation
-- ============================================

-- Add username column to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS username VARCHAR(50) UNIQUE;

-- Create index on username for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Add comment
COMMENT ON COLUMN users.username IS 'Unique username for login (alternative to email)';

-- Update existing users to have username (if needed)
-- This sets username to email prefix for existing users without username
-- You can modify this based on your requirements
UPDATE users 
SET username = SPLIT_PART(email, '@', 1) || '_' || SUBSTRING(user_id::text, 1, 8)
WHERE username IS NULL;

