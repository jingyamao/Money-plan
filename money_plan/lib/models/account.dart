class Account {
  final String id;
  final String name;
  final String type; // 'alipay', 'wechat', 'cash'
  final double balance;

  Account({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
    );
  }
}
