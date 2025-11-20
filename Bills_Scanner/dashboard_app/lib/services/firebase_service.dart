import 'package:firebase_database/firebase_database.dart';
import '../models/project_data.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref('billScanner/progress');

  /// Watch for real-time updates from Firebase
  Stream<ProjectData?> watchProgress() {
    return _ref.onValue.map((event) {
      if (event.snapshot.value == null) return null;

      try {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return ProjectData.fromJson(data);
      } catch (e) {
        print('Error parsing Firebase data: $e');
        return null;
      }
    });
  }

  /// Get current data once (no real-time updates)
  Future<ProjectData?> getProgress() async {
    try {
      final snapshot = await _ref.get();
      if (snapshot.value == null) return null;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return ProjectData.fromJson(data);
    } catch (e) {
      print('Error fetching from Firebase: $e');
      return null;
    }
  }

  /// Save complete project data
  Future<void> saveProgress(ProjectData data) async {
    try {
      final jsonData = data.toJson();
      jsonData['lastUpdated'] = DateTime.now().toIso8601String();
      jsonData['source'] = 'mobile';

      await _ref.set(jsonData);
      print('✅ Data synced to Firebase');
    } catch (e) {
      print('❌ Error syncing to Firebase: $e');
      rethrow;
    }
  }

  /// Update a single task completion status
  Future<void> updateTaskStatus({
    required String phaseId,
    required int taskIndex,
    required bool completed,
  }) async {
    try {
      await _ref.child('phases/$phaseId/tasks/$taskIndex/completed').set(completed);
      print('✅ Task status updated');
    } catch (e) {
      print('❌ Error updating task: $e');
      rethrow;
    }
  }

  /// Update phase status
  Future<void> updatePhaseStatus({
    required String phaseId,
    required String status,
  }) async {
    try {
      await _ref.child('phases/$phaseId/status').set(status);
      print('✅ Phase status updated');
    } catch (e) {
      print('❌ Error updating phase: $e');
      rethrow;
    }
  }

  /// Clear all data (for testing)
  Future<void> clearData() async {
    try {
      await _ref.remove();
      print('✅ Data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }

  /// Check connection status
  Stream<bool> get connectionStatus {
    return FirebaseDatabase.instance
        .ref('.info/connected')
        .onValue
        .map((event) => event.snapshot.value as bool? ?? false);
  }
}

