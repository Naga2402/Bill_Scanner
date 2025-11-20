class Bill {
  final String billId;
  final String userId;
  final String vendorName;
  final double amount;
  final String currency;
  final DateTime billDate;
  final String? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final String? description;
  final String? imagePath;
  final bool isPaid;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bill({
    required this.billId,
    required this.userId,
    required this.vendorName,
    required this.amount,
    this.currency = 'USD',
    required this.billDate,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    this.description,
    this.imagePath,
    this.isPaid = true,
    this.isRecurring = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bill.fromMap(Map<String, dynamic> map) {
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

    return Bill(
      billId: map['bill_id'] as String,
      userId: map['user_id'] as String,
      vendorName: map['vendor_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      billDate: parseDateTime(map['bill_date']),
      categoryId: map['category_id'] as String?,
      categoryName: map['category_name'] as String?,
      categoryColor: map['category_color'] as String?,
      description: map['description'] as String?,
      imagePath: map['image_path'] as String?,
      isPaid: map['is_paid'] as bool? ?? true,
      isRecurring: map['is_recurring'] as bool? ?? false,
      createdAt: parseDateTime(map['created_at']),
      updatedAt: parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bill_id': billId,
      'user_id': userId,
      'vendor_name': vendorName,
      'amount': amount,
      'currency': currency,
      'bill_date': billDate,
      'category_id': categoryId,
      'description': description,
      'image_path': imagePath,
      'is_paid': isPaid,
      'is_recurring': isRecurring,
    };
  }
}

