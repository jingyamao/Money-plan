class CategoryBudget {
  final String id;
  final String category;
  final double amount;
  final String period; // 'weekly', 'monthly', 'yearly'

  CategoryBudget({
    required this.id,
    required this.category,
    required this.amount,
    this.period = 'monthly',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'period': period,
    };
  }

  factory CategoryBudget.fromMap(Map<String, dynamic> map) {
    return CategoryBudget(
      id: map['id'],
      category: map['category'],
      amount: map['amount'].toDouble(),
      period: map['period'] ?? 'monthly',
    );
  }
}
