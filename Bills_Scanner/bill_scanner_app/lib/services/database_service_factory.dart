// ============================================
// Database Service Factory
// ============================================
// This factory returns the appropriate service based on platform
// - Web: Uses WebApiService (HTTP API calls with mock fallback)
// - Mobile/Desktop: Uses DatabaseService (Direct PostgreSQL connection)

import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';
import '../models/bill_model.dart';
import '../models/category_model.dart';
import 'database_service.dart';
import 'web_api_service.dart';

/// Common interface for database operations
abstract class IDatabaseService {
  Future<User?> authenticateUser(String emailOrUsername, String password);
  Future<User?> createUser({required String email, required String password, required String username, required String fullName});
  Future<User?> getUserById(String userId);
  Future<List<Bill>> getUserBills(String userId, {DateTime? startDate, DateTime? endDate, String? categoryId, String? vendorName, int limit = 50, int offset = 0});
  Future<Bill?> createBill({required String userId, required String vendorName, required double amount, required DateTime billDate, String? categoryId, String? description, String? imagePath, String currency = 'USD'});
  Future<List<Category>> getCategories({String? userId});
  Future<Map<String, dynamic>?> getUserSettings(String userId);
  Future<bool> updateUserSettings({required String userId, String? currency, String? appearanceMode, String? defaultCategory, bool? pushNotificationsEnabled, bool? emailNotificationsEnabled, bool? billRemindersEnabled});
  Future<String?> createPasswordResetToken(String email);
  Future<bool> resetPassword({required String token, required String newPassword});
}

/// Factory to get the appropriate database service based on platform
class DatabaseServiceFactory {
  static IDatabaseService getService() {
    if (kIsWeb) {
      // Web platform - use HTTP API (with mock fallback for development)
      print('🌐 Using WebApiService for web platform');
      return WebApiService();
    } else {
      // Mobile/Desktop platform - use direct PostgreSQL connection
      print('📱 Using DatabaseService for mobile/desktop platform');
      return DatabaseService();
    }
  }
}

