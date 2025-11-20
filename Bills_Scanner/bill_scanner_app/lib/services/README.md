# Database Service

## Overview

Production-ready database service for the Bill Scanner app. Handles all PostgreSQL database operations with proper error handling, connection management, and security.

## Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure database connection:**
   Edit `lib/services/database_service.dart` and update:
   ```dart
   final String _host = 'localhost'; // Your database host
   final String _username = 'postgres'; // Your username
   final String _password = 'your_password'; // Your password
   ```

3. **Run database setup:**
   ```bash
   psql -U postgres -d bill_scanner_db -f database/Bills_Scanner_ConsolidatedScripts.sql
   ```

## Usage

### Initialize Service

```dart
import 'package:bill_scanner_app/services/database_service.dart';

final db = DatabaseService();
```

### User Authentication

```dart
// Login
final user = await db.authenticateUser('email@example.com', 'password');
if (user != null) {
  // User authenticated successfully
}

// Sign Up
final newUser = await db.createUser(
  email: 'email@example.com',
  password: 'password',
  fullName: 'John Doe',
);
```

### Bills Management

```dart
// Get user bills
final bills = await db.getUserBills(
  userId,
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 12, 31),
  categoryId: categoryId, // optional
  limit: 50,
);

// Create bill
final bill = await db.createBill(
  userId: userId,
  vendorName: 'Amazon',
  amount: 128.70,
  billDate: DateTime.now(),
  categoryId: categoryId,
  description: 'Online purchase',
);

// Update bill
final updatedBill = await db.updateBill(
  billId: billId,
  vendorName: 'Amazon Prime',
  amount: 150.00,
);

// Delete bill
final deleted = await db.deleteBill(billId);
```

### Categories

```dart
// Get all categories
final categories = await db.getCategories(userId: userId);

// Create custom category
final category = await db.createCategory(
  userId: userId,
  name: 'Entertainment',
  color: '#FF5722',
  icon: 'movie',
);
```

### User Settings

```dart
// Get settings
final settings = await db.getUserSettings(userId);

// Update settings
await db.updateUserSettings(
  userId: userId,
  currency: 'USD',
  appearanceMode: 'dark',
  pushNotificationsEnabled: true,
);
```

### Password Reset

```dart
// Create reset token
final token = await db.createPasswordResetToken('email@example.com');

// Reset password
final success = await db.resetPassword(
  token: token,
  newPassword: 'newPassword123',
);
```

## Features

✅ **Production Ready:**
- Proper password hashing with bcrypt
- Connection pooling
- Error handling
- Transaction support

✅ **Complete CRUD Operations:**
- User management
- Bills management
- Categories management
- Settings management

✅ **Security:**
- Password hashing
- SQL injection prevention (parameterized queries)
- Token-based password reset

✅ **Type Safety:**
- Strongly typed models
- Null safety
- Proper error handling

## Models

- `User` - User account model
- `Bill` - Bill/expense model
- `Category` - Category model

## Error Handling

All methods return nullable types or empty lists on error. Check the return values:

```dart
final user = await db.authenticateUser(email, password);
if (user == null) {
  // Handle authentication failure
}
```

## Next Steps

1. Add environment variable support for database credentials
2. Implement connection retry logic
3. Add database migration system
4. Implement caching layer
5. Add logging/monitoring

