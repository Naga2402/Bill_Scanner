class User {
  final String userId;
  final String email;
  final String? username;
  final String? fullName;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final bool emailVerified;

  User({
    required this.userId,
    required this.email,
    this.username,
    this.fullName,
    required this.createdAt,
    this.lastLogin,
    required this.isActive,
    required this.emailVerified,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    // Parse date strings from API (ISO 8601 format)
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return User(
      userId: map['user_id'] as String,
      email: map['email'] as String,
      username: map['username'] as String?,
      fullName: map['full_name'] as String?,
      createdAt: parseDateTime(map['created_at']) ?? DateTime.now(),
      lastLogin: parseDateTime(map['last_login']),
      isActive: map['is_active'] as bool? ?? true,
      emailVerified: map['email_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'email': email,
      'username': username,
      'full_name': fullName,
      'created_at': createdAt,
      'last_login': lastLogin,
      'is_active': isActive,
      'email_verified': emailVerified,
    };
  }
}

