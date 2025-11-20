import 'package:hive/hive.dart';

part 'project_data.g.dart';

@HiveType(typeId: 0)
class ProjectData {
  @HiveField(0)
  final String startDate;

  @HiveField(1)
  final List<Phase> phases;

  @HiveField(2)
  final String? lastUpdated;

  ProjectData({
    required this.startDate,
    required this.phases,
    this.lastUpdated,
  });

  factory ProjectData.fromJson(Map<String, dynamic> json) {
    return ProjectData(
      startDate: json['startDate'] ?? '2025-10-21',
      phases: (json['phases'] as List?)
              ?.map((p) => Phase.fromJson(Map<String, dynamic>.from(p)))
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'phases': phases.map((p) => p.toJson()).toList(),
      'lastUpdated': lastUpdated,
    };
  }

  ProjectData copyWith({
    String? startDate,
    List<Phase>? phases,
    String? lastUpdated,
  }) {
    return ProjectData(
      startDate: startDate ?? this.startDate,
      phases: phases ?? this.phases,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

@HiveType(typeId: 1)
class Phase {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String emoji;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String weeks;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final List<Task> tasks;

  Phase({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.weeks,
    required this.status,
    required this.tasks,
  });

  factory Phase.fromJson(Map<String, dynamic> json) {
    return Phase(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '',
      description: json['description'] ?? '',
      weeks: json['weeks'] ?? '',
      status: json['status'] ?? 'not-started',
      tasks: (json['tasks'] as List?)
              ?.map((t) => Task.fromJson(Map<String, dynamic>.from(t)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'description': description,
      'weeks': weeks,
      'status': status,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  int get completedTasksCount => tasks.where((t) => t.completed).length;
  int get totalTasksCount => tasks.length;
  double get progress =>
      totalTasksCount > 0 ? completedTasksCount / totalTasksCount : 0.0;
  int get progressPercentage => (progress * 100).round();
}

@HiveType(typeId: 2)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String owner;

  @HiveField(4)
  final String priority;

  @HiveField(5)
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.owner,
    required this.priority,
    required this.completed,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      owner: json['owner'] ?? '',
      priority: json['priority'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'owner': owner,
      'priority': priority,
      'completed': completed,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? owner,
    String? priority,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
    );
  }
}

