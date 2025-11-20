// ============================================
// Bill Scanner App - PostgreSQL Connection Example
// ============================================
// This is a Flutter/Dart example for connecting to PostgreSQL
// You'll need to add the postgres package to pubspec.yaml

/*
Add to pubspec.yaml:
dependencies:
  postgres: ^3.0.0
  or
  postgresql2: ^0.2.0
*/

import 'dart:io';
import 'package:postgres/postgres.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  PostgreSQLConnection? _connection;

  // Database configuration
  final String _host = 'localhost'; // Change to your database host
  final int _port = 5432;
  final String _databaseName = 'bill_scanner_db';
  final String _username = 'postgres'; // Change to your username
  final String _password = 'your_password'; // Change to your password

  Future<PostgreSQLConnection> get connection async {
    if (_connection != null && _connection!.isClosed == false) {
      return _connection!;
    }

    _connection = PostgreSQLConnection(
      _host,
      _port,
      _databaseName,
      username: _username,
      password: _password,
      timeoutInSeconds: 30,
    );

    await _connection!.open();
    return _connection!;
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  // Example: User Authentication
  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    try {
      final conn = await connection;
      
      // Get user by email
      final result = await conn.query(
        'SELECT user_id, email, password_hash, full_name FROM users WHERE email = @email AND is_active = TRUE',
        parameters: {'email': email},
      );

      if (result.isEmpty) {
        return null; // User not found
      }

      final user = result.first;
      final storedHash = user['password_hash'] as String;

      // Verify password (you'll need bcrypt package)
      // final isValid = await bcrypt.verify(password, storedHash);
      // For now, just return user data (implement proper password verification)
      
      // Update last login
      await conn.query(
        'UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE user_id = @user_id',
        parameters: {'user_id': user['user_id']},
      );

      return {
        'user_id': user['user_id'],
        'email': user['email'],
        'full_name': user['full_name'],
      };
    } catch (e) {
      print('Database error: $e');
      return null;
    }
  }

  // Example: Create User
  Future<Map<String, dynamic>?> createUser({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final conn = await connection;
      
      // Hash password (use bcrypt package)
      // final passwordHash = await bcrypt.hash(password);
      final passwordHash = password; // TODO: Implement proper hashing

      final result = await conn.query(
        '''
        INSERT INTO users (email, password_hash, full_name, email_verified)
        VALUES (@email, @password_hash, @full_name, FALSE)
        RETURNING user_id, email, full_name, created_at
        ''',
        parameters: {
          'email': email,
          'password_hash': passwordHash,
          'full_name': fullName ?? '',
        },
      );

      if (result.isEmpty) {
        return null;
      }

      final user = result.first;

      // Create default settings
      await conn.query(
        '''
        INSERT INTO user_settings (user_id)
        VALUES (@user_id)
        ''',
        parameters: {'user_id': user['user_id']},
      );

      return {
        'user_id': user['user_id'],
        'email': user['email'],
        'full_name': user['full_name'],
        'created_at': user['created_at'],
      };
    } catch (e) {
      print('Database error: $e');
      return null;
    }
  }

  // Example: Get User Bills
  Future<List<Map<String, dynamic>>> getUserBills(String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final conn = await connection;
      
      String query = '''
        SELECT 
          b.bill_id,
          b.vendor_name,
          b.amount,
          b.bill_date,
          b.description,
          b.is_paid,
          c.name as category_name,
          c.color as category_color
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

      query += ' ORDER BY b.bill_date DESC LIMIT @limit OFFSET @offset';
      parameters['limit'] = limit;
      parameters['offset'] = offset;

      final result = await conn.query(query, parameters: parameters);

      return result.map((row) => {
        return {
          'bill_id': row['bill_id'],
          'vendor_name': row['vendor_name'],
          'amount': row['amount'],
          'bill_date': row['bill_date'],
          'description': row['description'],
          'is_paid': row['is_paid'],
          'category_name': row['category_name'],
          'category_color': row['category_color'],
        };
      }).toList();
    } catch (e) {
      print('Database error: $e');
      return [];
    }
  }

  // Example: Create Bill
  Future<Map<String, dynamic>?> createBill({
    required String userId,
    required String vendorName,
    required double amount,
    required DateTime billDate,
    String? categoryId,
    String? description,
    String? imagePath,
  }) async {
    try {
      final conn = await connection;
      
      final result = await conn.query(
        '''
        INSERT INTO bills (
          user_id, vendor_name, amount, bill_date, 
          category_id, description, image_path, is_paid
        )
        VALUES (
          @user_id, @vendor_name, @amount, @bill_date,
          @category_id, @description, @image_path, TRUE
        )
        RETURNING bill_id, vendor_name, amount, bill_date, created_at
        ''',
        parameters: {
          'user_id': userId,
          'vendor_name': vendorName,
          'amount': amount,
          'bill_date': billDate,
          'category_id': categoryId,
          'description': description ?? '',
          'image_path': imagePath,
        },
      );

      if (result.isEmpty) {
        return null;
      }

      final bill = result.first;
      return {
        'bill_id': bill['bill_id'],
        'vendor_name': bill['vendor_name'],
        'amount': bill['amount'],
        'bill_date': bill['bill_date'],
        'created_at': bill['created_at'],
      };
    } catch (e) {
      print('Database error: $e');
      return null;
    }
  }
}

