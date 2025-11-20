// ============================================
// Web API Service - For Flutter Web
// ============================================
// Since postgres package doesn't work in web browsers,
// we need to use HTTP API calls to a backend server
// 
// TODO: Create a backend API server (Node.js/Express, Python/Flask, etc.)
// that connects to PostgreSQL and exposes REST endpoints

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/bill_model.dart';
import '../models/category_model.dart';
import 'database_service_factory.dart';

class WebApiService implements IDatabaseService {
  static final WebApiService _instance = WebApiService._internal();
  factory WebApiService() => _instance;
  WebApiService._internal();

  // Backend API base URL
  // Update this to match your Python Flask backend server
  final String _baseUrl = 'http://localhost:5000/api'; // Python Flask backend
  // For production: 'https://your-backend.com/api'
  // For network access: 'http://192.168.0.110:5000/api'

  // ============================================
  // USER AUTHENTICATION
  // ============================================

  Future<User?> authenticateUser(String emailOrUsername, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_or_username': emailOrUsername,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromMap(data['user'] as Map<String, dynamic>);
      } else {
        final errorData = jsonDecode(response.body);
        print('Login failed: ${response.statusCode} - ${errorData['error']}');
        return null;
      }
    } catch (e) {
      print('API error in authenticateUser: $e');
      print('Make sure the backend server is running on $_baseUrl');
      rethrow; // Re-throw to show error in UI
    }
  }

  Future<User?> createUser({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      // Build request body with required fields
      final Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
        'username': username.trim(),
        'full_name': fullName.trim(),
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromMap(data['user'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create user: ${response.body}');
      }
    } catch (e) {
      print('API error in createUser: $e');
      rethrow;
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromMap(data['user'] as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('API error in getUserById: $e');
      return null;
    }
  }

  Future<bool> resetPassword({required String token, required String newPassword}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('API error in resetPassword: $e');
      return false;
    }
  }

  // ============================================
  // BILLS MANAGEMENT
  // ============================================

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
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (vendorName != null) queryParams['vendor_name'] = vendorName;

      final uri = Uri.parse('$_baseUrl/bills/$userId').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> billsJson = data['bills'] as List<dynamic>;
        return billsJson.map((json) => Bill.fromMap(json as Map<String, dynamic>)).toList();
      } else {
        print('Get bills failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('API error in getUserBills: $e');
      print('Make sure the backend server is running on $_baseUrl');
      return []; // Return empty list on error
    }
  }

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
      final response = await http.post(
        Uri.parse('$_baseUrl/bills'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'vendor_name': vendorName,
          'amount': amount,
          'bill_date': billDate.toIso8601String(),
          'category_id': categoryId,
          'description': description,
          'image_path': imagePath,
          'currency': currency,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Bill.fromMap(data['bill'] as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('API error in createBill: $e');
      return null;
    }
  }

  // ============================================
  // CATEGORIES
  // ============================================

  Future<List<Category>> getCategories({String? userId}) async {
    try {
      final uri = userId != null
          ? Uri.parse('$_baseUrl/categories?user_id=$userId')
          : Uri.parse('$_baseUrl/categories');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> categoriesJson = data['categories'] as List<dynamic>;
        return categoriesJson.map((json) => Category.fromMap(json as Map<String, dynamic>)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('API error in getCategories: $e');
      print('Make sure the backend server is running on $_baseUrl');
      return []; // Return empty list on error
    }
  }

  // ============================================
  // USER SETTINGS
  // ============================================

  Future<Map<String, dynamic>?> getUserSettings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/$userId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['settings'] as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('API error in getUserSettings: $e');
      return null;
    }
  }

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
      final response = await http.put(
        Uri.parse('$_baseUrl/settings/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (currency != null) 'currency': currency,
          if (appearanceMode != null) 'appearance_mode': appearanceMode,
          if (defaultCategory != null) 'default_category': defaultCategory,
          if (pushNotificationsEnabled != null) 'push_notifications_enabled': pushNotificationsEnabled,
          if (emailNotificationsEnabled != null) 'email_notifications_enabled': emailNotificationsEnabled,
          if (billRemindersEnabled != null) 'bill_reminders_enabled': billRemindersEnabled,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('API error in updateUserSettings: $e');
      return false;
    }
  }

  // ============================================
  // PASSWORD RESET
  // ============================================

  Future<String?> createPasswordResetToken(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('API error in createPasswordResetToken: $e');
      return null;
    }
  }

}

