-- ============================================
-- Bill Scanner App - Set PostgreSQL User Password
-- ============================================
-- This script helps you set or change the postgres user password
-- Run this as a PostgreSQL superuser

-- ============================================
-- METHOD 1: Set password for postgres user
-- ============================================
-- Replace 'your_new_password' with your desired password
ALTER USER postgres WITH PASSWORD 'your_new_password';

-- ============================================
-- METHOD 2: Create a new user for the app (Recommended)
-- ============================================
-- This is more secure than using the postgres superuser
-- Replace 'bill_scanner_user' and 'your_password' with your values
CREATE USER bill_scanner_user WITH PASSWORD 'your_password';

-- Grant necessary privileges
GRANT ALL PRIVILEGES ON DATABASE bill_scanner_db TO bill_scanner_user;

-- Connect to the database and grant schema privileges
\c bill_scanner_db;
GRANT ALL ON SCHEMA public TO bill_scanner_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO bill_scanner_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO bill_scanner_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO bill_scanner_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO bill_scanner_user;

-- ============================================
-- METHOD 3: Check current user password (if using pgAdmin)
-- ============================================
-- In pgAdmin, you can:
-- 1. Right-click on "Login/Group Roles" → "postgres"
-- 2. Go to "Definition" tab
-- 3. Set or change the password there
-- 4. Click "Save"

-- ============================================
-- NOTES:
-- ============================================
-- 1. If you just installed PostgreSQL, the default password might be:
--    - Empty (no password) - for local development
--    - The password you set during installation
--    - Check your installation notes or pgAdmin configuration
--
-- 2. To test connection without password (if allowed):
--    psql -U postgres -d bill_scanner_db
--
-- 3. To test connection with password:
--    psql -U postgres -d bill_scanner_db -W
--    (It will prompt for password)
--
-- 4. Update the password in database_service.dart after setting it:
--    final String _password = 'your_actual_password';

