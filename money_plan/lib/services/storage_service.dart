import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/fixed_transaction.dart';
import '../models/category_budget.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 交易记录
  Future<void> saveTransactions(List<Transaction> transactions) async {
    final jsonList = transactions.map((t) => t.toMap()).toList();
    await _prefs.setString('transactions', jsonEncode(jsonList));
  }

  List<Transaction> getTransactions() {
    final jsonStr = _prefs.getString('transactions');
    if (jsonStr == null) return [];
    final jsonList = jsonDecode(jsonStr) as List;
    return jsonList.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final transactions = getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  // 预算
  Future<void> saveBudgets(List<Budget> budgets) async {
    final jsonList = budgets.map((b) => b.toMap()).toList();
    await _prefs.setString('budgets', jsonEncode(jsonList));
  }

  List<Budget> getBudgets() {
    final jsonStr = _prefs.getString('budgets');
    if (jsonStr == null) return [];
    final jsonList = jsonDecode(jsonStr) as List;
    return jsonList.map((map) => Budget.fromMap(map)).toList();
  }

  // 存款目标
  Future<void> saveSavingsGoals(List<SavingsGoal> goals) async {
    final jsonList = goals.map((g) => g.toMap()).toList();
    await _prefs.setString('savings_goals', jsonEncode(jsonList));
  }

  List<SavingsGoal> getSavingsGoals() {
    final jsonStr = _prefs.getString('savings_goals');
    if (jsonStr == null) return [];
    final jsonList = jsonDecode(jsonStr) as List;
    return jsonList.map((map) => SavingsGoal.fromMap(map)).toList();
  }

  // 月度预算设置
  Future<void> setMonthlyBudget(double amount) async {
    await _prefs.setDouble('monthly_budget', amount);
  }

  double getMonthlyBudget() {
    return _prefs.getDouble('monthly_budget') ?? 0;
  }

  // 当前存款
  Future<void> setCurrentSavings(double amount) async {
    await _prefs.setDouble('current_savings', amount);
  }

  double getCurrentSavings() {
    return _prefs.getDouble('current_savings') ?? 0;
  }

  // 月收入
  Future<void> setMonthlyIncome(double amount) async {
    await _prefs.setDouble('monthly_income', amount);
  }

  double getMonthlyIncome() {
    return _prefs.getDouble('monthly_income') ?? 0;
  }

  // 固定收支
  Future<void> saveFixedTransaction(FixedTransaction fixed) async {
    final list = getFixedTransactions();
    final index = list.indexWhere((f) => f.id == fixed.id);
    if (index != -1) {
      list[index] = fixed;
    } else {
      list.add(fixed);
    }
    final jsonList = list.map((f) => f.toMap()).toList();
    await _prefs.setString('fixed_transactions', jsonEncode(jsonList));
  }

  List<FixedTransaction> getFixedTransactions() {
    final jsonStr = _prefs.getString('fixed_transactions');
    if (jsonStr == null) return [];
    final jsonList = jsonDecode(jsonStr) as List;
    return jsonList.map((map) => FixedTransaction.fromMap(map)).toList();
  }

  Future<void> deleteFixedTransaction(String id) async {
    final list = getFixedTransactions();
    list.removeWhere((f) => f.id == id);
    final jsonList = list.map((f) => f.toMap()).toList();
    await _prefs.setString('fixed_transactions', jsonEncode(jsonList));
  }

  // 分类预算
  Future<void> saveCategoryBudget(CategoryBudget budget) async {
    final list = getCategoryBudgets();
    final index = list.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      list[index] = budget;
    } else {
      list.add(budget);
    }
    final jsonList = list.map((b) => b.toMap()).toList();
    await _prefs.setString('category_budgets', jsonEncode(jsonList));
  }

  List<CategoryBudget> getCategoryBudgets() {
    final jsonStr = _prefs.getString('category_budgets');
    if (jsonStr == null) return [];
    final jsonList = jsonDecode(jsonStr) as List;
    return jsonList.map((map) => CategoryBudget.fromMap(map)).toList();
  }

  Future<void> deleteCategoryBudget(String id) async {
    final list = getCategoryBudgets();
    list.removeWhere((b) => b.id == id);
    final jsonList = list.map((b) => b.toMap()).toList();
    await _prefs.setString('category_budgets', jsonEncode(jsonList));
  }

  // 预算周期
  Future<void> setBudgetPeriod(String period) async {
    await _prefs.setString('budget_period', period);
  }

  String getBudgetPeriod() {
    return _prefs.getString('budget_period') ?? 'monthly';
  }
}
