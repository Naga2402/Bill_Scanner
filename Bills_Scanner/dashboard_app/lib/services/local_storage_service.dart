import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_data.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _boxName = 'dashboard_data';
  static const String _dataKey = 'project_data';
  static const String _lastSyncKey = 'last_sync';

  Box<ProjectData>? _box;
  SharedPreferences? _prefs;

  /// Initialize Hive and SharedPreferences
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters (after code generation)
    // Hive.registerAdapter(ProjectDataAdapter());
    // Hive.registerAdapter(PhaseAdapter());
    // Hive.registerAdapter(TaskAdapter());
    
    _prefs = await SharedPreferences.getInstance();
    // _box = await Hive.openBox<ProjectData>(_boxName);
  }

  /// Save project data locally
  Future<void> saveProjectData(ProjectData data) async {
    try {
      // For now, use SharedPreferences as Hive needs code generation
      final jsonString = data.toJson().toString();
      await _prefs?.setString(_dataKey, jsonString);
      await _prefs?.setString(_lastSyncKey, DateTime.now().toIso8601String());
      print('✅ Data saved locally');
    } catch (e) {
      print('❌ Error saving locally: $e');
      rethrow;
    }
  }

  /// Get cached project data
  ProjectData? getCachedData() {
    try {
      // Implementation depends on your caching strategy
      return null; // TODO: Implement proper caching
    } catch (e) {
      print('❌ Error reading cache: $e');
      return null;
    }
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    final syncString = _prefs?.getString(_lastSyncKey);
    if (syncString == null) return null;
    return DateTime.tryParse(syncString);
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await _prefs?.remove(_dataKey);
      await _prefs?.remove(_lastSyncKey);
      print('✅ Cache cleared');
    } catch (e) {
      print('❌ Error clearing cache: $e');
      rethrow;
    }
  }

  /// Check if data is stale (older than 5 minutes)
  bool isDataStale() {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return true;
    
    final difference = DateTime.now().difference(lastSync);
    return difference.inMinutes > 5;
  }
}

