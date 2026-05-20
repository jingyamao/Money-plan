enum BudgetPeriod { weekly, monthly, yearly }

class Budget {
  final String id;
  final String? category;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime? endDate;

  Budget({
    required this.id,
    this.category,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'period': period.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      amount: map['amount'].toDouble(),
      period: BudgetPeriod.values.byName(map['period']),
      startDate: DateTime.parse(map['start_date']),
      endDate:
          map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
    );
  }
}
