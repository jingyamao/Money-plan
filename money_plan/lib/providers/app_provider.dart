import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<SavingsGoal> _savingsGoals = [];
  double _monthlyBudget = 0;
  double _currentSavings = 0;
  double _monthlyIncome = 0;

  AppProvider() {
    _loadData();
  }

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  List<SavingsGoal> get savingsGoals => _savingsGoals;
  double get monthlyBudget => _monthlyBudget;
  double get currentSavings => _currentSavings;
  double get monthlyIncome => _monthlyIncome;

  void _loadData() {
    _transactions = _storage.getTransactions();
    _budgets = _storage.getBudgets();
    _savingsGoals = _storage.getSavingsGoals();
    _monthlyBudget = _storage.getMonthlyBudget();
    _currentSavings = _storage.getCurrentSavings();
    _monthlyIncome = _storage.getMonthlyIncome();
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
    final daysInMonth =
        DateTime(now.year, now.month + 1, 0).day;
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
    notifyListeners();
  }

  // 删除交易
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  // 设置月度预算
  Future<void> setMonthlyBudget(double amount) async {
    _monthlyBudget = amount;
    await _storage.setMonthlyBudget(amount);
    notifyListeners();
  }

  // 设置当前存款
  Future<void> setCurrentSavings(double amount) async {
    _currentSavings = amount;
    await _storage.setCurrentSavings(amount);
    notifyListeners();
  }

  // 设置月收入
  Future<void> setMonthlyIncome(double amount) async {
    _monthlyIncome = amount;
    await _storage.setMonthlyIncome(amount);
    notifyListeners();
  }

  // 添加存款目标
  Future<void> addSavingsGoal(SavingsGoal goal) async {
    _savingsGoals.add(goal);
    await _storage.saveSavingsGoals(_savingsGoals);
    notifyListeners();
  }

  // 更新存款目标
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    final index = _savingsGoals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _savingsGoals[index] = goal;
      await _storage.saveSavingsGoals(_savingsGoals);
      notifyListeners();
    }
  }

  // 删除存款目标
  Future<void> deleteSavingsGoal(String id) async {
    _savingsGoals.removeWhere((g) => g.id == id);
    await _storage.saveSavingsGoals(_savingsGoals);
    notifyListeners();
  }

  // 预算使用百分比
  double get budgetUsagePercent {
    if (_monthlyBudget <= 0) return 0;
    return (monthlySpent / _monthlyBudget).clamp(0, 1);
  }
}
