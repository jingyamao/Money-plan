import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../services/ai_service.dart';
import '../../widgets/cards/budget_card.dart';
import '../../widgets/cards/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _aiInsight = '正在分析您的消费情况...';

  @override
  void initState() {
    super.initState();
    _loadAiInsight();
  }

  Future<void> _loadAiInsight() async {
    final provider = context.read<AppProvider>();
    final insight = await AiService().analyzeSpending(
      monthlyBudget: provider.monthlyBudget,
      monthlySpent: provider.monthlySpent,
      todaySpent: provider.todaySpent,
      categoryBreakdown: provider.categoryBreakdown,
    );
    if (mounted) {
      setState(() => _aiInsight = insight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Money Plan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: _loadAiInsight,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 概览卡片
                  _buildOverviewCard(provider),
                  const SizedBox(height: 16),

                  // 预算进度
                  BudgetCard(
                    budget: provider.monthlyBudget,
                    spent: provider.monthlySpent,
                    dailyAvailable: provider.dailyAvailable,
                  ),
                  const SizedBox(height: 16),

                  // AI 洞察
                  _buildAiInsightCard(),
                  const SizedBox(height: 16),

                  // 最近交易
                  _buildRecentTransactions(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewItem(
                '今日消费',
                '¥${provider.todaySpent.toStringAsFixed(2)}',
                Icons.today,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildOverviewItem(
                '本月剩余',
                '¥${provider.monthlyRemaining.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewItem(
                '当前存款',
                '¥${provider.currentSavings.toStringAsFixed(0)}',
                Icons.savings,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildOverviewItem(
                '月收入',
                '¥${provider.monthlyIncome.toStringAsFixed(0)}',
                Icons.trending_up,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI 洞察',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _aiInsight,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(AppProvider provider) {
    final recentTransactions = provider.transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '最近交易',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('查看全部'),
            ),
          ],
        ),
        if (recentTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 48, color: AppTheme.textHint),
                  SizedBox(height: 8),
                  Text(
                    '暂无交易记录',
                    style: TextStyle(color: AppTheme.textHint),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '点击下方 + 开始记账',
                    style: TextStyle(
                        color: AppTheme.textHint, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ...recentTransactions.map((t) => TransactionTile(transaction: t)),
      ],
    );
  }
}
