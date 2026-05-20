class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final int priority;
  final DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.targetDate,
    this.priority = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress =>
      targetAmount > 0 ? currentAmount / targetAmount : 0;

  int get daysRemaining {
    if (targetDate == null) return -1;
    return targetDate!.difference(DateTime.now()).inDays;
  }

  double get dailySavingNeeded {
    if (targetDate == null || daysRemaining <= 0) return 0;
    final remaining = targetAmount - currentAmount;
    return remaining / daysRemaining;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate?.toIso8601String(),
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      name: map['name'],
      targetAmount: map['target_amount'].toDouble(),
      currentAmount: map['current_amount']?.toDouble() ?? 0,
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'])
          : null,
      priority: map['priority'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    int? priority,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
    );
  }
}
