import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:postgres/postgres.dart';
import 'package:bcrypt/bcrypt.dart';
import '../models/user_model.dart';
import '../models/bill_model.dart';
import '../models/category_model.dart';
import 'database_service_factory.dart';

/// Production-ready database service for Bill Scanner app
/// Handles all database operations with proper error handling and connection management
/// NOTE: This service only works on mobile/desktop platforms, NOT on web
class DatabaseService implements IDatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Connection? _connection;
  bool _isConnecting = false;

  // Database configuration - TODO: Move to environment variables or config file
  // 
  // IMPORTANT: Set your PostgreSQL password here!
  // To find/set password:
  // 1. In pgAdmin: Servers → Login/Group Roles → postgres → Properties → Definition tab
  // 2. Or run: ALTER USER postgres WITH PASSWORD 'your_password';
  // 3. For local dev, password might be empty (leave as empty string)
  // 4. See database/HOW_TO_FIND_PASSWORD.md for detailed instructions
  //
  final String _host = '192.168.0.110'; // Change to your database host
  final int _port = 5432;
  final String _databaseName = 'bill_scanner_db'; // Must match database name in SQL scripts
  final String _username = 'postgres'; // Change to your username
  final String _password = 'billscanner'; // ⚠️ SET YOUR PASSWORD HERE! (or leave empty for local dev)

  /// Get database connection (with connection pooling)
  Future<Connection> get connection async {
    // Return existing connection if available
    if (_connection != null) {
      return _connection!;
    }

    // Wait if another connection attempt is in progress
    if (_isConnecting) {
      while (_isConnecting) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_connection != null) {
        return _connection!;
      }
    }

    // Create new connection
    _isConnecting = true;
    try {
      _connection = await Connection.open(
        Endpoint(
          host: _host,
          port: _port,
          database: _databaseName,
          username: _username,
          password: _password,
        ),
        settings: ConnectionSettings(
          connectTimeout: const Duration(seconds: 30),
        ),
      );
      return _connection!;
    } catch (e) {
      _connection = null;
      throw Exception('Failed to connect to database: $e');
    } finally {
      _isConnecting = false;
    }
  }

  /// Close database connection
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  // ============================================
  // USER AUTHENTICATION & MANAGEMENT
  // ============================================

  /// Authenticate user with email/username and password
  Future<User?> authenticateUser(String emailOrUsername, String password) async {
    try {
      final conn = await connection;

      // Get user by email or username
      final result = await conn.execute(
        Sql.named(
          '''
          SELECT user_id, email, username, password_hash, full_name, created_at, 
                 last_login, is_active, email_verified
          FROM users 
          WHERE (email = @identifier OR username = @identifier) AND is_active = TRUE
          '''
        ),
        parameters: {'identifier': emailOrUsername},
      );

      if (result.isEmpty) {
        return null; // User not found
      }

      final user = result.first.toColumnMap();
      final storedHash = user['password_hash'] as String;

      // Verify password using bcrypt
      final isValid = BCrypt.checkpw(password, storedHash);
      if (!isValid) {
        return null; // Invalid password
      }

      // Update last login
      await conn.execute(
        Sql.named(
          '''
          UPDATE users 
          SET last_login = CURRENT_TIMESTAMP 
          WHERE user_id = @user_id
          '''
        ),
        parameters: {'user_id': user['user_id']},
      );

      return User.fromMap({
        'user_id': user['user_id'],
        'email': user['email'],
        'username': user['username'],
        'full_name': user['full_name'],
        'created_at': user['created_at'],
        'last_login': DateTime.now(),
        'is_active': user['is_active'],
        'email_verified': user['email_verified'],
      });
    } catch (e) {
      print('Database error in authenticateUser: $e');
      return null;
    }
  }

  /// Create new user account
  Future<User?> createUser({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      final conn = await connection;

      // Check if email already exists
      final existingEmail = await conn.execute(
        Sql.named('SELECT user_id FROM users WHERE email = @email'),
        parameters: {'email': email},
      );

      if (existingEmail.isNotEmpty) {
        throw Exception('Email already exists');
      }

      // Check if username already exists
      final existingUsername = await conn.execute(
        Sql.named('SELECT user_id FROM users WHERE username = @username'),
        parameters: {'username': username},
      );

      if (existingUsername.isNotEmpty) {
        throw Exception('Username already exists');
      }

      // Hash password using bcrypt
      final salt = BCrypt.gensalt();
      final passwordHash = BCrypt.hashpw(password, salt);

      // Create user
      final result = await conn.execute(
        Sql.named(
          '''
          INSERT INTO users (email, username, password_hash, full_name, email_verified)
          VALUES (@email, @username, @password_hash, @full_name, FALSE)
          RETURNING user_id, email, username, full_name, created_at, is_active, email_verified
          '''
        ),
        parameters: {
          'email': email,
          'username': username,
          'password_hash': passwordHash,
          'full_name': fullName,
        },
      );

      if (result.isEmpty) {
        return null;
      }

      final user = result.first.toColumnMap();

      // Create default settings
      await conn.execute(
        Sql.named(
          '''
          INSERT INTO user_settings (user_id)
          VALUES (@user_id)
          '''
        ),
        parameters: {'user_id': user['user_id']},
      );

      return User.fromMap({
        'user_id': user['user_id'],
        'email': user['email'],
        'username': user['username'],
        'full_name': user['full_name'],
        'created_at': user['created_at'],
        'is_active': user['is_active'],
        'email_verified': user['email_verified'],
      });
    } catch (e) {
      print('Database error in createUser: $e');
      rethrow;
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final conn = await connection;

      final result = await conn.execute(
        Sql.named(
          '''
          SELECT user_id, email, full_name, created_at, last_login, 
                 is_active, email_verified
          FROM users 
          WHERE user_id = @user_id
          '''
        ),
        parameters: {'user_id': userId},
      );

      if (result.isEmpty) {
        return null;
      }

      return User.fromMap(result.first.toColumnMap());
    } catch (e) {
      print('Database error in getUserById: $e');
      return null;
    }
  }

  // ============================================
  // BILLS MANAGEMENT
  // ============================================

  /// Get user bills with optional filters
  Future<List<Bill>> getUserBills(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? vendorName,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final conn = await connection;

      String query = '''
        SELECT 
          b.bill_id,
          b.user_id,
          b.vendor_name,
          b.amount,
          b.currency,
          b.bill_date,
          b.category_id,
          c.name as category_name,
          c.color as category_color,
          b.description,
          b.image_path,
          b.is_paid,
          b.is_recurring,
          b.created_at,
          b.updated_at
        FROM bills b
        LEFT JOIN categories c ON b.category_id = c.category_id
        WHERE b.user_id = @user_id
      ''';

      final parameters = <String, dynamic>{'user_id': userId};

      if (startDate != null) {
        query += ' AND b.bill_date >= @start_date';
        parameters['start_date'] = startDate;
      }

      if (endDate != null) {
        query += ' AND b.bill_date <= @end_date';
        parameters['end_date'] = endDate;
      }

      if (categoryId != null) {
        query += ' AND b.category_id = @category_id';
        parameters['category_id'] = categoryId;
      }

      if (vendorName != null && vendorName.isNotEmpty) {
        query += ' AND b.vendor_name ILIKE @vendor_name';
        parameters['vendor_name'] = '%$vendorName%';
      }

      query += ' ORDER BY b.bill_date DESC LIMIT @limit OFFSET @offset';
      parameters['limit'] = limit;
      parameters['offset'] = offset;

      final result = await conn.execute(
        Sql.named(query),
        parameters: parameters,
      );

      return result.map((row) => Bill.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('Database error in getUserBills: $e');
      return [];
    }
  }

  /// Create a new bill
  Future<Bill?> createBill({
    required String userId,
    required String vendorName,
    required double amount,
    required DateTime billDate,
    String? categoryId,
    String? description,
    String? imagePath,
    String currency = 'USD',
  }) async {
    try {
      final conn = await connection;

      final result = await conn.execute(
        Sql.named(
          '''
          INSERT INTO bills (
            user_id, vendor_name, amount, bill_date, 
            category_id, description, image_path, currency, is_paid
          )
          VALUES (
            @user_id, @vendor_name, @amount, @bill_date,
            @category_id, @description, @image_path, @currency, TRUE
          )
          RETURNING bill_id, user_id, vendor_name, amount, currency, bill_date,
                    category_id, description, image_path, is_paid, is_recurring,
                    created_at, updated_at
          '''
        ),
        parameters: {
          'user_id': userId,
          'vendor_name': vendorName,
          'amount': amount,
          'bill_date': billDate,
          'category_id': categoryId,
          'description': description ?? '',
          'image_path': imagePath,
          'currency': currency,
        },
      );

      if (result.isEmpty) {
        return null;
      }

      final row = result.first.toColumnMap();
      
      // Get category info if category_id exists
      if (row['category_id'] != null) {
        final categoryResult = await conn.execute(
          Sql.named('SELECT name, color FROM categories WHERE category_id = @category_id'),
          parameters: {'category_id': row['category_id']},
        );
        if (categoryResult.isNotEmpty) {
          final cat = categoryResult.first.toColumnMap();
          row['category_name'] = cat['name'];
          row['category_color'] = cat['color'];
        }
      }

      return Bill.fromMap(row);
    } catch (e) {
      print('Database error in createBill: $e');
      return null;
    }
  }

  /// Update a bill
  Future<Bill?> updateBill({
    required String billId,
    String? vendorName,
    double? amount,
    DateTime? billDate,
    String? categoryId,
    String? description,
    bool? isPaid,
  }) async {
    try {
      final conn = await connection;

      // Build dynamic update query
      final updates = <String>[];
      final parameters = <String, dynamic>{'bill_id': billId};

      if (vendorName != null) {
        updates.add('vendor_name = @vendor_name');
        parameters['vendor_name'] = vendorName;
      }
      if (amount != null) {
        updates.add('amount = @amount');
        parameters['amount'] = amount;
      }
      if (billDate != null) {
        updates.add('bill_date = @bill_date');
        parameters['bill_date'] = billDate;
      }
      if (categoryId != null) {
        updates.add('category_id = @category_id');
        parameters['category_id'] = categoryId;
      }
      if (description != null) {
        updates.add('description = @description');
        parameters['description'] = description;
      }
      if (isPaid != null) {
        updates.add('is_paid = @is_paid');
        parameters['is_paid'] = isPaid;
      }

      if (updates.isEmpty) {
        return await getBillById(billId);
      }

      await conn.execute(
        Sql.named(
          '''
          UPDATE bills 
          SET ${updates.join(', ')}
          WHERE bill_id = @bill_id
          '''
        ),
        parameters: parameters,
      );

      return await getBillById(billId);
    } catch (e) {
      print('Database error in updateBill: $e');
      return null;
    }
  }

  /// Get bill by ID
  Future<Bill?> getBillById(String billId) async {
    try {
      final conn = await connection;

      final result = await conn.execute(
        Sql.named(
          '''
          SELECT 
            b.bill_id, b.user_id, b.vendor_name, b.amount, b.currency,
            b.bill_date, b.category_id, c.name as category_name,
            c.color as category_color, b.description, b.image_path,
            b.is_paid, b.is_recurring, b.created_at, b.updated_at
          FROM bills b
          LEFT JOIN categories c ON b.category_id = c.category_id
          WHERE b.bill_id = @bill_id
          '''
        ),
        parameters: {'bill_id': billId},
      );

      if (result.isEmpty) {
        return null;
      }

      return Bill.fromMap(result.first.toColumnMap());
    } catch (e) {
      print('Database error in getBillById: $e');
      return null;
    }
  }

  /// Delete a bill
  Future<bool> deleteBill(String billId) async {
    try {
      final conn = await connection;

      final result = await conn.execute(
        Sql.named('DELETE FROM bills WHERE bill_id = @bill_id'),
        parameters: {'bill_id': billId},
      );

      return result.affectedRows > 0;
    } catch (e) {
      print('Database error in deleteBill: $e');
      return false;
    }
  }

  // ============================================
  // CATEGORIES MANAGEMENT
  // ============================================

  /// Get all categories (default + user-specific)
  Future<List<Category>> getCategories({String? userId}) async {
    try {
      final conn = await connection;

      final result = await conn.execute(
        Sql.named(
          '''
          SELECT category_id, user_id, name, color, icon, is_default, created_at
          FROM categories
          WHERE (user_id IS NULL OR user_id = @user_id)
          ORDER BY is_default DESC, name ASC
          '''
        ),
        parameters: {'user_id': userId},
      );

      return result.map((row) => Category.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('Database error in getCategories: $e');
      return [];
    }
  }

  /// Create a user-specific category
  Future<Category?> createCategory({
    required String userId,
    required String name,
    String? color,
    String? icon,
  }) async {
    try {
      final conn = await connection;

      final result = await conn.execute(
        Sql.named(
          '''
          INSERT INTO categories (user_id, name, color, icon, is_default)
          VALUES (@user_id, @name, @color, @icon, FALSE)
          RETURNING category_id, user_id, name, color, icon, is_default, created_at
          '''
        ),
        parameters: {
          'user_id': userId,
          'name': name,
          'color': color,
          'icon': icon,
        },
      );

      if (result.isEmpty) {
        return null;
      }

      return Category.fromMap(result.first.toColumnMap());
    } catch (e) {
      print('Database error in createCategory: $e');
      return null;
    }
  }

  // ============================================
  // USER SETTINGS
  // ============================================

  /// Get user settings
  Future<Map<String, dynamic>?> getUserSettings(String userId) async {
    try {
      final conn = await connection;

      final result = await conn.execute(
        Sql.named(
          '''
          SELECT setting_id, user_id, currency, appearance_mode, 
                 default_category, push_notifications_enabled,
                 email_notifications_enabled, bill_reminders_enabled
          FROM user_settings
          WHERE user_id = @user_id
          '''
        ),
        parameters: {'user_id': userId},
      );

      if (result.isEmpty) {
        return null;
      }

      return result.first.toColumnMap();
    } catch (e) {
      print('Database error in getUserSettings: $e');
      return null;
    }
  }

  /// Update user settings
  Future<bool> updateUserSettings({
    required String userId,
    String? currency,
    String? appearanceMode,
    String? defaultCategory,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? billRemindersEnabled,
  }) async {
    try {
      final conn = await connection;

      final updates = <String>[];
      final parameters = <String, dynamic>{'user_id': userId};

      if (currency != null) {
        updates.add('currency = @currency');
        parameters['currency'] = currency;
      }
      if (appearanceMode != null) {
        updates.add('appearance_mode = @appearance_mode');
        parameters['appearance_mode'] = appearanceMode;
      }
      if (defaultCategory != null) {
        updates.add('default_category = @default_category');
        parameters['default_category'] = defaultCategory;
      }
      if (pushNotificationsEnabled != null) {
        updates.add('push_notifications_enabled = @push_notifications_enabled');
        parameters['push_notifications_enabled'] = pushNotificationsEnabled;
      }
      if (emailNotificationsEnabled != null) {
        updates.add('email_notifications_enabled = @email_notifications_enabled');
        parameters['email_notifications_enabled'] = emailNotificationsEnabled;
      }
      if (billRemindersEnabled != null) {
        updates.add('bill_reminders_enabled = @bill_reminders_enabled');
        parameters['bill_reminders_enabled'] = billRemindersEnabled;
      }

      if (updates.isEmpty) {
        return true;
      }

      final result = await conn.execute(
        Sql.named(
          '''
          UPDATE user_settings 
          SET ${updates.join(', ')}
          WHERE user_id = @user_id
          '''
        ),
        parameters: parameters,
      );

      return result.affectedRows > 0;
    } catch (e) {
      print('Database error in updateUserSettings: $e');
      return false;
    }
  }

  // ============================================
  // PASSWORD RESET
  // ============================================

  /// Create password reset token
  Future<String?> createPasswordResetToken(String email) async {
    try {
      final conn = await connection;

      // Get user by email
      final userResult = await conn.execute(
        Sql.named('SELECT user_id FROM users WHERE email = @email AND is_active = TRUE'),
        parameters: {'email': email},
      );

      if (userResult.isEmpty) {
        return null; // User not found
      }

      final userId = userResult.first.toColumnMap()['user_id'] as String;

      // Generate token (you can use a UUID or random string)
      final token = DateTime.now().millisecondsSinceEpoch.toString() +
          userId.substring(0, 8);

      // Store token (expires in 1 hour)
      await conn.execute(
        Sql.named(
          '''
          INSERT INTO password_reset_tokens (user_id, token, expires_at)
          VALUES (@user_id, @token, CURRENT_TIMESTAMP + INTERVAL '1 hour')
          '''
        ),
        parameters: {
          'user_id': userId,
          'token': token,
        },
      );

      return token;
    } catch (e) {
      print('Database error in createPasswordResetToken: $e');
      return null;
    }
  }

  /// Reset password using token
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final conn = await connection;

      // Verify token
      final tokenResult = await conn.execute(
        Sql.named(
          '''
          SELECT user_id FROM password_reset_tokens
          WHERE token = @token 
            AND expires_at > CURRENT_TIMESTAMP 
            AND used = FALSE
          '''
        ),
        parameters: {'token': token},
      );

      if (tokenResult.isEmpty) {
        return false; // Invalid or expired token
      }

      final userId = tokenResult.first.toColumnMap()['user_id'] as String;

      // Hash new password
      final salt = BCrypt.gensalt();
      final passwordHash = BCrypt.hashpw(newPassword, salt);

      // Update password
      await conn.execute(
        Sql.named(
          '''
          UPDATE users 
          SET password_hash = @password_hash
          WHERE user_id = @user_id
          '''
        ),
        parameters: {
          'user_id': userId,
          'password_hash': passwordHash,
        },
      );

      // Mark token as used
      await conn.execute(
        Sql.named(
          '''
          UPDATE password_reset_tokens
          SET used = TRUE
          WHERE token = @token
          '''
        ),
        parameters: {'token': token},
      );

      return true;
    } catch (e) {
      print('Database error in resetPassword: $e');
      return false;
    }
  }
}
