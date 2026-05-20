enum TransactionType { income, expense }

enum TransactionSource { manual, alipay, wechat, import }

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final String? description;
  final String? merchant;
  final DateTime transactionDate;
  final TransactionSource source;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    this.merchant,
    required this.transactionDate,
    this.source = TransactionSource.manual,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'category': category,
      'description': description,
      'merchant': merchant,
      'transaction_date': transactionDate.toIso8601String(),
      'source': source.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'].toDouble(),
      type: TransactionType.values.byName(map['type']),
      category: map['category'],
      description: map['description'],
      merchant: map['merchant'],
      transactionDate: DateTime.parse(map['transaction_date']),
      source: TransactionSource.values.byName(map['source']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? category,
    String? description,
    String? merchant,
    DateTime? transactionDate,
    TransactionSource? source,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      transactionDate: transactionDate ?? this.transactionDate,
      source: source ?? this.source,
    );
  }
}
