import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';
import '../models/transaction.dart';
import '../models/savings_goal.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // 初始化 Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  // 获取当前用户
  User? get currentUser => client.auth.currentUser;

  // 邮箱注册
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // 邮箱登录
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 登出
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // 保存交易记录
  Future<void> saveTransaction(Transaction transaction) async {
    final userId = currentUser?.id;
    if (userId == null) {
      print('saveTransaction: userId is null');
      return;
    }

    try {
      await client.from('transactions').upsert({
        'id': transaction.id,
        'user_id': userId,
        'amount': transaction.amount,
        'type': transaction.type.name,
        'category': transaction.category,
        'description': transaction.description,
        'merchant': transaction.merchant,
        'transaction_date': transaction.transactionDate.toIso8601String(),
        'source': transaction.source.name,
        'created_at': transaction.createdAt.toIso8601String(),
      });
      print('Transaction saved: ${transaction.id}');
    } catch (e) {
      print('saveTransaction error: $e');
    }
  }

  // 获取交易记录
  Future<List<Transaction>> getTransactions() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('transaction_date', ascending: false);

    return (response as List).map((map) => Transaction.fromMap(map)).toList();
  }

  // 删除交易记录
  Future<void> deleteTransaction(String id) async {
    await client.from('transactions').delete().eq('id', id);
  }

  // 保存存款目标
  Future<void> saveSavingsGoal(SavingsGoal goal) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await client.from('savings_goals').upsert({
      'id': goal.id,
      'user_id': userId,
      'name': goal.name,
      'target_amount': goal.targetAmount,
      'current_amount': goal.currentAmount,
      'target_date': goal.targetDate?.toIso8601String(),
      'priority': goal.priority,
      'created_at': goal.createdAt.toIso8601String(),
    });
  }

  // 获取存款目标
  Future<List<SavingsGoal>> getSavingsGoals() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('savings_goals')
        .select()
        .eq('user_id', userId)
        .order('priority', ascending: true);

    return (response as List).map((map) => SavingsGoal.fromMap(map)).toList();
  }

  // 删除存款目标
  Future<void> deleteSavingsGoal(String id) async {
    await client.from('savings_goals').delete().eq('id', id);
  }

  // 保存用户设置
  Future<void> saveUserSettings({
    required double monthlyBudget,
    required double currentSavings,
    required double monthlyIncome,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) {
      print('saveUserSettings: userId is null');
      return;
    }

    try {
      await client.from('user_settings').upsert({
        'user_id': userId,
        'monthly_budget': monthlyBudget,
        'current_savings': currentSavings,
        'monthly_income': monthlyIncome,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('User settings saved');
    } catch (e) {
      print('saveUserSettings error: $e');
    }
  }

  // 获取用户设置
  Future<Map<String, double>> getUserSettings() async {
    final userId = currentUser?.id;
    if (userId == null) {
      return {
        'monthly_budget': 0,
        'current_savings': 0,
        'monthly_income': 0,
      };
    }

    final response = await client
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      return {
        'monthly_budget': 0,
        'current_savings': 0,
        'monthly_income': 0,
      };
    }

    return {
      'monthly_budget': (response['monthly_budget'] as num).toDouble(),
      'current_savings': (response['current_savings'] as num).toDouble(),
      'monthly_income': (response['monthly_income'] as num).toDouble(),
    };
  }
}
