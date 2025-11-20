# 🗄️ Bill Scanner - PostgreSQL Database

## 📋 Overview

This directory contains PostgreSQL database scripts for the Bill Scanner application.

## 📁 Files

1. **01_create_database.sql** - Creates the database (run this first)
2. **Bills_Scanner_ConsolidatedScripts.sql** - ⭐ **MAIN SCRIPT** - All setup scripts combined (recommended)
3. **02_create_tables.sql** - Creates all tables and relationships (included in consolidated)
4. **03_create_indexes.sql** - Performance optimization indexes (included in consolidated)
5. **04_sample_data.sql** - Sample data for testing (included in consolidated)
6. **05_connection_example.dart** - Flutter/Dart connection example

## 🚀 Setup Instructions

### Prerequisites

1. **Install PostgreSQL**
   - Download from: https://www.postgresql.org/download/
   - Or use Docker: `docker run -e POSTGRES_PASSWORD=yourpassword -p 5432:5432 postgres`

2. **Install Flutter PostgreSQL Package**
   ```yaml
   dependencies:
     postgres: ^3.0.0
     # or
     postgresql2: ^0.2.0
   ```

### Step 1: Create Database

```bash
# Connect to PostgreSQL as superuser
psql -U postgres

# Run the database creation script
\i database/01_create_database.sql
```

### Step 2: Run Consolidated Script (Recommended)

```bash
# Connect to the database
psql -U postgres -d bill_scanner_db

# Run the consolidated script (includes extensions, tables, indexes, and sample data)
\i database/Bills_Scanner_ConsolidatedScripts.sql
```

**OR** run individual scripts:

### Step 2a: Create Tables

```bash
# Connect to the database
psql -U postgres -d bill_scanner_db

# Run the table creation script
\i database/02_create_tables.sql
```

**Note:** If you encounter `uuid_generate_v4() does not exist` error:
- The script now automatically creates the extensions, but if you still see the error, run:
```bash
\i database/00_check_and_fix_extensions.sql
```

### Step 3: Create Indexes (Optional but Recommended)

```bash
\i database/03_create_indexes.sql
```

### Step 4: Insert Sample Data (Optional)

```bash
\i database/04_sample_data.sql
```

## 📊 Database Schema

### Tables

1. **users** - User accounts
2. **user_settings** - User preferences
3. **categories** - Bill categories
4. **bills** - Scanned bills and expenses
5. **bill_images** - Bill image files
6. **export_history** - Export history
7. **password_reset_tokens** - Password reset tokens
8. **notifications** - User notifications

## 🔐 Security Notes

- **Password Hashing**: Use bcrypt for password hashing
- **Connection Security**: Use SSL for production connections
- **Environment Variables**: Store database credentials in environment variables
- **Connection Pooling**: Use connection pooling for production

## 🔧 Configuration

Update connection details in `05_connection_example.dart`:

```dart
final String _host = 'localhost';
final int _port = 5432;
final String _databaseName = 'bill_scanner_db';
final String _username = 'postgres';
final String _password = 'your_password';
```

## 📝 Usage in Flutter

```dart
import 'database_service.dart';

// Initialize
final db = DatabaseService();

// Authenticate user
final user = await db.authenticateUser('email@example.com', 'password');

// Get bills
final bills = await db.getUserBills(userId);

// Create bill
final bill = await db.createBill(
  userId: userId,
  vendorName: 'Amazon',
  amount: 128.70,
  billDate: DateTime.now(),
);
```

## 🧪 Testing

```bash
# Connect to database
psql -U postgres -d bill_scanner_db

# Test queries
SELECT * FROM users;
SELECT * FROM bills;
SELECT * FROM categories;
```

## 🔧 Troubleshooting

### Error: `function uuid_generate_v4() does not exist`

**Solution 1:** Run the fix script:
```bash
psql -U postgres -d bill_scanner_db -f database/00_check_and_fix_extensions.sql
```

**Solution 2:** Manually create extensions:
```sql
\c bill_scanner_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

### Error: `permission denied to create extension`

**Solution:** Run as superuser (postgres):
```bash
psql -U postgres -d bill_scanner_db
```

## 📚 Additional Resources

- PostgreSQL Documentation: https://www.postgresql.org/docs/
- Flutter PostgreSQL Package: https://pub.dev/packages/postgres

---

**Note**: Remember to change default passwords and secure your database in production!

