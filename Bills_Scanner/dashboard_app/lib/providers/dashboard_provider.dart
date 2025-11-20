import 'package:flutter/material.dart';
import 'dart:async';

import '../models/project_data.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';

class DashboardProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final LocalStorageService _localStorageService = LocalStorageService();

  ProjectData? _projectData;
  bool _isLoading = true;
  bool _isConnected = false;
  String? _errorMessage;
  StreamSubscription? _dataSubscription;
  StreamSubscription? _connectionSubscription;

  ProjectData? get projectData => _projectData;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;
  bool get hasData => _projectData != null;

  DashboardProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _localStorageService.initialize();
      _listenToConnection();
      _listenToData();
    } catch (e) {
      _errorMessage = 'Initialization error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _listenToConnection() {
    _connectionSubscription = _firebaseService.connectionStatus.listen((connected) {
      _isConnected = connected;
      notifyListeners();
    });
  }

  void _listenToData() {
    _dataSubscription = _firebaseService.watchProgress().listen(
      (data) {
        _projectData = data;
        _isLoading = false;
        _errorMessage = null;
        
        if (data != null) {
          _localStorageService.saveProjectData(data);
        }
        
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Data sync error: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Toggle task completion
  Future<void> toggleTask(String phaseId, int taskIndex) async {
    if (_projectData == null) return;

    try {
      // Find phase index
      final phaseIndex = _projectData!.phases.indexWhere((p) => p.id == phaseId);
      if (phaseIndex == -1) return;

      final phase = _projectData!.phases[phaseIndex];
      if (taskIndex < 0 || taskIndex >= phase.tasks.length) return;

      // Toggle task locally first (optimistic update)
      final task = phase.tasks[taskIndex];
      final updatedTask = task.copyWith(completed: !task.completed);
      
      final updatedTasks = List<Task>.from(phase.tasks);
      updatedTasks[taskIndex] = updatedTask;

      final updatedPhase = Phase(
        id: phase.id,
        name: phase.name,
        emoji: phase.emoji,
        description: phase.description,
        weeks: phase.weeks,
        status: _calculatePhaseStatus(updatedTasks),
        tasks: updatedTasks,
      );

      final updatedPhases = List<Phase>.from(_projectData!.phases);
      updatedPhases[phaseIndex] = updatedPhase;

      _projectData = _projectData!.copyWith(phases: updatedPhases);
      notifyListeners();

      // Sync to Firebase
      await _firebaseService.saveProgress(_projectData!);
    } catch (e) {
      _errorMessage = 'Error toggling task: $e';
      notifyListeners();
    }
  }

  String _calculatePhaseStatus(List<Task> tasks) {
    final completedCount = tasks.where((t) => t.completed).length;
    if (completedCount == 0) return 'not-started';
    if (completedCount == tasks.length) return 'completed';
    return 'in-progress';
  }

  /// Get overall statistics
  Map<String, dynamic> getStatistics() {
    if (_projectData == null) {
      return {
        'totalProgress': 0,
        'completedTasks': 0,
        'totalTasks': 0,
        'currentPhase': 'N/A',
        'activePhases': 0,
        'remainingTasks': 0,
        'tasksPerDay': 0.0,
        'daysElapsed': 0,
      };
    }

    final allTasks = _projectData!.phases.expand((p) => p.tasks).toList();
    final completedTasks = allTasks.where((t) => t.completed).length;
    final totalTasks = allTasks.length;
    final progress = totalTasks > 0 ? ((completedTasks / totalTasks) * 100).round() : 0;

    final currentPhase = _projectData!.phases.firstWhere(
      (p) => p.status == 'in-progress',
      orElse: () => _projectData!.phases.first,
    );

    final activePhases = _projectData!.phases.where((p) => p.status == 'in-progress').length;

    final startDate = DateTime.tryParse(_projectData!.startDate);
    final daysElapsed = startDate != null
        ? DateTime.now().difference(startDate).inDays
        : 0;

    final tasksPerDay = daysElapsed > 0 ? (completedTasks / daysElapsed) : 0.0;

    return {
      'totalProgress': progress,
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'currentPhase': currentPhase.name.split('—')[0].trim(),
      'activePhases': activePhases,
      'remainingTasks': totalTasks - completedTasks,
      'tasksPerDay': tasksPerDay,
      'daysElapsed': daysElapsed,
    };
  }

  /// Refresh data manually
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _firebaseService.getProgress();
      if (data != null) {
        _projectData = data;
        await _localStorageService.saveProjectData(data);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Refresh error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
}

