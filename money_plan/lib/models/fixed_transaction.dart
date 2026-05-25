enum FixedType { income, expense }

class FixedTransaction {
  final String id;
  final String name;
  final double amount;
  final FixedType type;
  final String category;
  final int dayOfMonth; // 每月几号执行
  final bool isActive;
  final DateTime createdAt;

  FixedTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.category,
    required this.dayOfMonth,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type.name,
      'category': category,
      'day_of_month': dayOfMonth,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FixedTransaction.fromMap(Map<String, dynamic> map) {
    return FixedTransaction(
      id: map['id'],
      name: map['name'],
      amount: map['amount'].toDouble(),
      type: FixedType.values.byName(map['type']),
      category: map['category'],
      dayOfMonth: map['day_of_month'],
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
