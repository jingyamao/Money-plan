import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/fixed_transaction.dart';
import '../models/savings_goal.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

class TestDataService {
  static final TestDataService _instance = TestDataService._internal();
  factory TestDataService() => _instance;
  TestDataService._internal();

  final StorageService _storage = StorageService();
  final SupabaseService _supabase = SupabaseService();

  // 创建测试账户并登录
  Future<bool> createAndLoginTestAccount() async {
    const email = '3377824726@qq.com';
    const password = '123456';

    try {
      // 先尝试登录
      var result = await _supabase.signIn(email: email, password: password);

      if (result.user == null) {
        // 登录失败，尝试注册
        result = await _supabase.signUp(email: email, password: password);
      }

      return result.user != null;
    } catch (e) {
      return false;
    }
  }

  // 清空所有数据
  Future<void> clearAllData() async {
    await _storage.saveTransactions([]);
    await _storage.saveSavingsGoals([]);
    await _storage.setMonthlyBudget(0);
    await _storage.setCurrentSavings(0);
    await _storage.setMonthlyIncome(0);
    await _storage.setPayday(15);

    // 清空固定收支
    final fixedList = _storage.getFixedTransactions();
    for (final f in fixedList) {
      await _storage.deleteFixedTransaction(f.id);
    }
  }

  // 设置基础数据
  Future<void> setupBaseData() async {
    // 月收入 17000
    await _storage.setMonthlyIncome(17000);

    // 存款 50000
    await _storage.setCurrentSavings(50000);

    // 生活费预算 4000
    await _storage.setMonthlyBudget(4000);

    // 发薪日 15号
    await _storage.setPayday(15);

    // 固定支出：房租 1800，每月15号
    await _storage.saveFixedTransaction(FixedTransaction(
      id: const Uuid().v4(),
      name: '房租',
      amount: 1800,
      type: FixedType.expense,
      category: '住房',
      dayOfMonth: 15,
    ));

    // 存款目标
    await _storage.saveSavingsGoals([
      SavingsGoal(
        id: const Uuid().v4(),
        name: '应急储备金',
        targetAmount: 100000,
        currentAmount: 50000,
        priority: 1,
      ),
      SavingsGoal(
        id: const Uuid().v4(),
        name: '旅行基金',
        targetAmount: 20000,
        currentAmount: 5000,
        targetDate: DateTime.now().add(const Duration(days: 180)),
        priority: 2,
      ),
    ]);
  }

  // 生成半年的模拟消费数据
  Future<void> generateHalfYearData() async {
    final now = DateTime.now();
    final transactions = <Transaction>[];

    // 生成过去6个月的数据
    for (int monthOffset = 5; monthOffset >= 0; monthOffset--) {
      final month = DateTime(now.year, now.month - monthOffset, 1);
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

      // 每月工资收入（15号）
      transactions.add(Transaction(
        id: const Uuid().v4(),
        amount: 17000,
        type: TransactionType.income,
        category: '工资',
        description: '月工资',
        transactionDate: DateTime(month.year, month.month, 15),
        source: TransactionSource.manual,
      ));

      // 每月房租（15号）
      transactions.add(Transaction(
        id: const Uuid().v4(),
        amount: 1800,
        type: TransactionType.expense,
        category: '住房',
        description: '月房租',
        transactionDate: DateTime(month.year, month.month, 15),
        source: TransactionSource.manual,
      ));

      // 模拟每日消费
      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(month.year, month.month, day);

        // 跳过未来日期
        if (date.isAfter(now)) break;

        // 跳过发薪日当天（已记录工资和房租）
        if (day == 15) continue;

        // 随机生成每日消费
        final dailyTransactions = _generateDailyTransactions(date);
        transactions.addAll(dailyTransactions);
      }
    }

    // 按日期排序
    transactions.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    // 保存
    await _storage.saveTransactions(transactions);
  }

  List<Transaction> _generateDailyTransactions(DateTime date) {
    final transactions = <Transaction>[];
    final random = date.day * 7 + date.month * 31; // 简单的伪随机

    // 早餐（70%概率）
    if (random % 10 < 7) {
      transactions.add(Transaction(
        id: const Uuid().v4(),
        amount: _randomAmount(8, 25, random),
        type: TransactionType.expense,
        category: '餐饮',
        description: '早餐',
        transactionDate: DateTime(date.year, date.month, date.day, 8),
        source: TransactionSource.manual,
      ));
    }

    // 午餐（90%概率）
    if (random % 10 < 9) {
      transactions.add(Transaction(
        id: const Uuid().v4(),
        amount: _randomAmount(15, 45, random + 1),
        type: TransactionType.expense,
        category: '餐饮',
        description: '午餐',
        transactionDate: DateTime(date.year, date.month, date.day, 12),
        source: TransactionSource.manual,
      ));
    }

    // 晚餐（80%概率）
    if (random % 10 < 8) {
      transactions.add(Transaction(
        id: const Uuid().v4(),
        amount: _randomAmount(20, 60, random + 2),
        type: TransactionType.expense,
        category: '餐饮',
        description: '晚餐',
        transactionDate: DateTime(date.year, date.month, date.day, 18),
        source: TransactionSource.manual,
      ));
    }

    // 交通（60%概率）
    if (random % 10 < 6) {
      transactions.add(Transaction(
        id: const Uuid().v4(),
        amount: _randomAmount(3, 15, random + 3),
        type: TransactionType.expense,
        category: '交通',
        description: '地铁/公交',
        transactionDate: DateTime(date.year, date.month, date.day, 9),
        source: TransactionSource.manual,
      ));
    }

    // 咖啡/奶茶（30%概率）
    if (random % 10 < 3) {
      transactions.add(Transaction(
        id: const Uuid().v4(),
        amount: _randomAmount(12, 35, random + 4),
        type: TransactionType.expense,
        category: '餐饮',
        description: '咖啡/奶茶',
        transactionDate: DateTime(date.year, date.month, date.day, 15),
        source: TransactionSource.manual,
      ));
    }

    // 购物（每周1-2次）
    if (random % 7 < 2) {
      transactions.add(Transaction(
        id: const Uuid().v4(),
        amount: _randomAmount(30, 200, random + 5),
        type: TransactionType.expense,
        category: '购物',
        description: _getRandomShoppingDesc(random),
        transactionDate: DateTime(date.year, date.month, date.day, 19),
        source: TransactionSource.alipay,
      ));
    }

    // 娱乐（每周1次）
    if (random % 7 == 3) {
      transactions.add(Transaction(
        id: const Uuid().v4(),
        amount: _randomAmount(50, 150, random + 6),
        type: TransactionType.expense,
        category: '娱乐',
        description: _getRandomEntertainmentDesc(random),
        transactionDate: DateTime(date.year, date.month, date.day, 20),
        source: TransactionSource.wechat,
      ));
    }

    // 生活缴费（每月1-2次）
    if (date.day == 5 || date.day == 20) {
      transactions.add(Transaction(
        id: const Uuid().v4(),
        amount: _randomAmount(50, 200, random + 7),
        type: TransactionType.expense,
        category: '生活',
        description: '水电燃气',
        transactionDate: DateTime(date.year, date.month, date.day, 10),
        source: TransactionSource.manual,
      ));
    }

    return transactions;
  }

  double _randomAmount(int min, int max, int seed) {
    final range = max - min;
    final value = min + (seed * 37 % range);
    return value.toDouble();
  }

  String _getRandomShoppingDesc(int seed) {
    final descs = ['日用品', '衣服', '数码配件', '零食', '水果', '生活用品'];
    return descs[seed % descs.length];
  }

  String _getRandomEntertainmentDesc(int seed) {
    final descs = ['电影', '聚餐', 'KTV', '游戏', '健身'];
    return descs[seed % descs.length];
  }
}
