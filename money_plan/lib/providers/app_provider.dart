import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final SupabaseService _supabase = SupabaseService();

  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<SavingsGoal> _savingsGoals = [];
  double _monthlyBudget = 0;
  double _currentSavings = 0;
  double _monthlyIncome = 0;
  bool _isLoggedIn = false;

  AppProvider() {
    _loadData();
    _loadTestDataIfEmpty();
    _checkAuthState();
  }

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  List<SavingsGoal> get savingsGoals => _savingsGoals;
  double get monthlyBudget => _monthlyBudget;
  double get currentSavings => _currentSavings;
  double get monthlyIncome => _monthlyIncome;
  bool get isLoggedIn => _isLoggedIn;

  void _checkAuthState() {
    _isLoggedIn = _supabase.currentUser != null;
    notifyListeners();
  }

  // 登录
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _supabase.signIn(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _isLoggedIn = true;
        await _syncFromCloud();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('登录失败: $e');
      return false;
    }
  }

  // 注册
  Future<bool> signUp(String email, String password) async {
    try {
      final response = await _supabase.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _isLoggedIn = true;
        await _syncToCloud();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('注册失败: $e');
      return false;
    }
  }

  // 登出
  Future<void> signOut() async {
    await _supabase.signOut();
    _isLoggedIn = false;
    notifyListeners();
  }

  // 从云端同步数据
  Future<void> _syncFromCloud() async {
    try {
      final cloudTransactions = await _supabase.getTransactions();
      if (cloudTransactions.isNotEmpty) {
        _transactions = cloudTransactions;
        await _storage.saveTransactions(_transactions);
      }

      final cloudGoals = await _supabase.getSavingsGoals();
      if (cloudGoals.isNotEmpty) {
        _savingsGoals = cloudGoals;
        await _storage.saveSavingsGoals(_savingsGoals);
      }

      final settings = await _supabase.getUserSettings();
      if (settings['monthly_budget']! > 0) {
        _monthlyBudget = settings['monthly_budget']!;
        _currentSavings = settings['current_savings']!;
        _monthlyIncome = settings['monthly_income']!;
        await _storage.setMonthlyBudget(_monthlyBudget);
        await _storage.setCurrentSavings(_currentSavings);
        await _storage.setMonthlyIncome(_monthlyIncome);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('云端同步失败: $e');
    }
  }

  // 同步到云端
  Future<void> _syncToCloud() async {
    if (!_isLoggedIn) return;

    try {
      for (final transaction in _transactions) {
        await _supabase.saveTransaction(transaction);
      }

      for (final goal in _savingsGoals) {
        await _supabase.saveSavingsGoal(goal);
      }

      await _supabase.saveUserSettings(
        monthlyBudget: _monthlyBudget,
        currentSavings: _currentSavings,
        monthlyIncome: _monthlyIncome,
      );
    } catch (e) {
      debugPrint('同步到云端失败: $e');
    }
  }

  void _loadData() {
    _transactions = _storage.getTransactions();
    _budgets = _storage.getBudgets();
    _savingsGoals = _storage.getSavingsGoals();
    _monthlyBudget = _storage.getMonthlyBudget();
    _currentSavings = _storage.getCurrentSavings();
    _monthlyIncome = _storage.getMonthlyIncome();
    notifyListeners();
  }

  void _loadTestDataIfEmpty() {
    if (_transactions.isEmpty) {
      _loadTestData();
    }
  }

  void _loadTestData() {
    final now = DateTime.now();

    _monthlyBudget = 5000;
    _currentSavings = 28500;
    _monthlyIncome = 12000;
    _storage.setMonthlyBudget(_monthlyBudget);
    _storage.setCurrentSavings(_currentSavings);
    _storage.setMonthlyIncome(_monthlyIncome);

    final testTransactions = [
      Transaction(
        id: '1',
        amount: 35.0,
        type: TransactionType.expense,
        category: '餐饮',
        description: '午餐 - 麦当劳',
        transactionDate: now,
        source: TransactionSource.manual,
      ),
      Transaction(
        id: '2',
        amount: 128.0,
        type: TransactionType.expense,
        category: '购物',
        description: '日用品采购',
        transactionDate: now,
        source: TransactionSource.manual,
      ),
      Transaction(
        id: '3',
        amount: 15.0,
        type: TransactionType.expense,
        category: '交通',
        description: '地铁充值',
        transactionDate: now.subtract(const Duration(days: 1)),
        source: TransactionSource.manual,
      ),
      Transaction(
        id: '4',
        amount: 268.0,
        type: TransactionType.expense,
        category: '娱乐',
        description: '电影票 + 晚餐',
        transactionDate: now.subtract(const Duration(days: 1)),
        source: TransactionSource.manual,
      ),
      Transaction(
        id: '5',
        amount: 45.0,
        type: TransactionType.expense,
        category: '餐饮',
        description: '外卖 - 火锅',
        transactionDate: now.subtract(const Duration(days: 2)),
        source: TransactionSource.manual,
      ),
      Transaction(
        id: '6',
        amount: 89.0,
        type: TransactionType.expense,
        category: '生活',
        description: '水电费',
        transactionDate: now.subtract(const Duration(days: 3)),
        source: TransactionSource.manual,
      ),
      Transaction(
        id: '7',
        amount: 12000.0,
        type: TransactionType.income,
        category: '其他',
        description: '工资',
        transactionDate: now.subtract(const Duration(days: 5)),
        source: TransactionSource.manual,
      ),
      Transaction(
        id: '8',
        amount: 199.0,
        type: TransactionType.expense,
        category: '购物',
        description: '衣服',
        transactionDate: now.subtract(const Duration(days: 4)),
        source: TransactionSource.manual,
      ),
      Transaction(
        id: '9',
        amount: 28.0,
        type: TransactionType.expense,
        category: '餐饮',
        description: '早餐 + 咖啡',
        transactionDate: now.subtract(const Duration(days: 2)),
        source: TransactionSource.manual,
      ),
      Transaction(
        id: '10',
        amount: 350.0,
        type: TransactionType.expense,
        category: '医疗',
        description: '体检',
        transactionDate: now.subtract(const Duration(days: 6)),
        source: TransactionSource.manual,
      ),
    ];

    _transactions = testTransactions;
    _storage.saveTransactions(_transactions);

    _savingsGoals = [
      SavingsGoal(
        id: '1',
        name: '买车基金',
        targetAmount: 150000,
        currentAmount: 28500,
        targetDate: now.add(const Duration(days: 365)),
        priority: 1,
      ),
      SavingsGoal(
        id: '2',
        name: '旅行基金',
        targetAmount: 15000,
        currentAmount: 8000,
        targetDate: now.add(const Duration(days: 180)),
        priority: 2,
      ),
      SavingsGoal(
        id: '3',
        name: '应急储备金',
        targetAmount: 30000,
        currentAmount: 22000,
        priority: 3,
      ),
    ];
    _storage.saveSavingsGoals(_savingsGoals);

    notifyListeners();
  }

  // 本月消费
  double get monthlySpent {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.transactionDate.isAfter(startOfMonth))
        .fold(0, (sum, t) => sum + t.amount);
  }

  // 今日消费
  double get todaySpent {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.transactionDate.isAfter(startOfDay))
        .fold(0, (sum, t) => sum + t.amount);
  }

  // 本月剩余预算
  double get monthlyRemaining => _monthlyBudget - monthlySpent;

  // 日均可用
  double get dailyAvailable {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1;
    return monthlyRemaining > 0 ? monthlyRemaining / daysRemaining : 0;
  }

  // 分类消费
  Map<String, double> get categoryBreakdown {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final Map<String, double> breakdown = {};

    for (final t in _transactions) {
      if (t.type == TransactionType.expense &&
          t.transactionDate.isAfter(startOfMonth)) {
        breakdown[t.category] = (breakdown[t.category] ?? 0) + t.amount;
      }
    }

    return breakdown;
  }

  // 添加交易
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _storage.saveTransactions(_transactions);
    if (_isLoggedIn) {
      await _supabase.saveTransaction(transaction);
    }
    notifyListeners();

    // 检查是否超支并发送通知
    if (transaction.type == TransactionType.expense) {
      _checkBudgetNotification();
    }
  }

  void _checkBudgetNotification() {
    if (_monthlyBudget <= 0) return;

    final spent = monthlySpent;
    final percent = spent / _monthlyBudget;

    // 超支提醒
    if (spent > _monthlyBudget) {
      NotificationService().showOverBudgetNotification(
        budget: _monthlyBudget,
        spent: spent,
      );
    }
    // 80% 预警
    else if (percent >= 0.8 && percent < 0.85) {
      NotificationService().showBudgetProgressNotification(
        budget: _monthlyBudget,
        spent: spent,
        percent: percent,
      );
    }
  }

  // 删除交易
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _storage.saveTransactions(_transactions);
    if (_isLoggedIn) {
      await _supabase.deleteTransaction(id);
    }
    notifyListeners();
  }

  // 更新交易
  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _storage.saveTransactions(_transactions);
      if (_isLoggedIn) {
        await _supabase.saveTransaction(transaction);
      }
      notifyListeners();
    }
  }

  // 设置月度预算
  Future<void> setMonthlyBudget(double amount) async {
    _monthlyBudget = amount;
    await _storage.setMonthlyBudget(amount);
    if (_isLoggedIn) {
      await _supabase.saveUserSettings(
        monthlyBudget: _monthlyBudget,
        currentSavings: _currentSavings,
        monthlyIncome: _monthlyIncome,
      );
    }
    notifyListeners();
  }

  // 设置当前存款
  Future<void> setCurrentSavings(double amount) async {
    _currentSavings = amount;
    await _storage.setCurrentSavings(amount);
    if (_isLoggedIn) {
      await _supabase.saveUserSettings(
        monthlyBudget: _monthlyBudget,
        currentSavings: _currentSavings,
        monthlyIncome: _monthlyIncome,
      );
    }
    notifyListeners();
  }

  // 设置月收入
  Future<void> setMonthlyIncome(double amount) async {
    _monthlyIncome = amount;
    await _storage.setMonthlyIncome(amount);
    if (_isLoggedIn) {
      await _supabase.saveUserSettings(
        monthlyBudget: _monthlyBudget,
        currentSavings: _currentSavings,
        monthlyIncome: _monthlyIncome,
      );
    }
    notifyListeners();
  }

  // 添加存款目标
  Future<void> addSavingsGoal(SavingsGoal goal) async {
    _savingsGoals.add(goal);
    await _storage.saveSavingsGoals(_savingsGoals);
    if (_isLoggedIn) {
      await _supabase.saveSavingsGoal(goal);
    }
    notifyListeners();
  }

  // 更新存款目标
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    final index = _savingsGoals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _savingsGoals[index] = goal;
      await _storage.saveSavingsGoals(_savingsGoals);
      if (_isLoggedIn) {
        await _supabase.saveSavingsGoal(goal);
      }
      notifyListeners();
    }
  }

  // 删除存款目标
  Future<void> deleteSavingsGoal(String id) async {
    _savingsGoals.removeWhere((g) => g.id == id);
    await _storage.saveSavingsGoals(_savingsGoals);
    if (_isLoggedIn) {
      await _supabase.deleteSavingsGoal(id);
    }
    notifyListeners();
  }

  // 预算使用百分比
  double get budgetUsagePercent {
    if (_monthlyBudget <= 0) return 0;
    return (monthlySpent / _monthlyBudget).clamp(0, 1);
  }

  // 是否超支
  bool get isOverBudget => monthlySpent > _monthlyBudget;
}
