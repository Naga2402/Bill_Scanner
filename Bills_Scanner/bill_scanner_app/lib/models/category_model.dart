class Category {
  final String categoryId;
  final String? userId; // NULL for default categories
  final String name;
  final String? color; // Hex color code
  final String? icon; // Icon name
  final bool isDefault;
  final DateTime createdAt;

  Category({
    required this.categoryId,
    this.userId,
    required this.name,
    this.color,
    this.icon,
    required this.isDefault,
    required this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    // Parse date strings from API (ISO 8601 format)
    DateTime parseDateTime(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return Category(
      categoryId: map['category_id'] as String,
      userId: map['user_id'] as String?,
      name: map['name'] as String,
      color: map['color'] as String?,
      icon: map['icon'] as String?,
      isDefault: map['is_default'] as bool? ?? false,
      createdAt: parseDateTime(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'user_id': userId,
      'name': name,
      'color': color,
      'icon': icon,
      'is_default': isDefault,
    };
  }
}

