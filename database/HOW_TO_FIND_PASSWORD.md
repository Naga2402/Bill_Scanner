# 🔐 How to Find/Set PostgreSQL Password

## 📋 Overview

PostgreSQL passwords are set at the **user/role level**, not the database level. The database properties dialog you see only shows database information, not user credentials.

---

## 🔍 Where to Find/Set the Password

### Option 1: Check pgAdmin (GUI Tool)

1. **Open pgAdmin**
2. **Navigate to:** `Servers` → `PostgreSQL [version]` → `Login/Group Roles`
3. **Right-click on `postgres`** → Select **"Properties"**
4. **Go to "Definition" tab**
5. **Password field** will be there (may be hidden/masked)
6. **To change:** Enter new password → Click **"Save"**

### Option 2: Check Installation Notes

If you installed PostgreSQL recently:
- Check the installation notes/README
- Check if you set a password during installation
- Default might be empty for local development

### Option 3: Test Connection

Try connecting without password first (if local):
```bash
psql -U postgres -d bill_scanner_db
```

If it asks for password, you'll know one is set.

### Option 4: Reset/Set Password via SQL

Run this in pgAdmin Query Tool or psql:
```sql
ALTER USER postgres WITH PASSWORD 'your_new_password';
```

---

## ⚙️ Update Flutter App

After you know/set the password, update `lib/services/database_service.dart`:

```dart
final String _password = 'your_actual_password'; // Line 24
```

---

## 🎯 Recommended: Create App-Specific User

Instead of using the `postgres` superuser, create a dedicated user:

```sql
-- Create user
CREATE USER bill_scanner_user WITH PASSWORD 'secure_password_123';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE bill_scanner_db TO bill_scanner_user;

-- Connect to database
\c bill_scanner_db;

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO bill_scanner_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO bill_scanner_user;
```

Then update `database_service.dart`:
```dart
final String _username = 'bill_scanner_user';
final String _password = 'secure_password_123';
```

---

## 🧪 Test Connection

After setting password, test it:

```bash
# Test with psql
psql -U postgres -d bill_scanner_db -W
# Enter password when prompted

# Or test with connection string
psql postgresql://postgres:your_password@localhost:5432/bill_scanner_db
```

---

## 📝 Quick Setup Script

Run `database/06_set_postgres_password.sql` to set up a password or create a new user.

---

**Note:** For local development, PostgreSQL often allows connections without a password. If that's the case, you can leave the password empty in `database_service.dart` (but this is not recommended for production).

