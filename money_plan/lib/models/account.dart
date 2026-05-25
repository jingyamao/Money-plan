class Account {
  final String id;
  final String name;
  final String type; // 'bank', 'alipay', 'wechat', 'cash', 'credit'
  final double balance;
  final String icon;
  final int sortOrder;

  Account({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0,
    this.icon = 'wallet',
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'icon': icon,
      'sort_order': sortOrder,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      icon: map['icon'] ?? 'wallet',
      sortOrder: map['sort_order'] ?? 0,
    );
  }
}
