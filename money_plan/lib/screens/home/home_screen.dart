import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../services/ai_service.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/animated_widgets.dart';
import '../../widgets/cards/transaction_tile.dart';
import '../transaction/add_transaction_screen.dart';
import '../transaction/edit_transaction_screen.dart';
import '../transaction/transaction_list_screen.dart';
import '../ai/ai_chat_screen.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, child) {
              return RefreshIndicator(
                onRefresh: _loadAiInsight,
                color: AppTheme.primaryColor,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // App Bar
                    SliverToBoxAdapter(
                      child: FadeSlideIn(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Money Plan',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      foreground: Paint()
                                        ..shader = const LinearGradient(
                                          colors: AppTheme.primaryGradient,
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 200, 70),
                                        ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '智能理财助手',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              GlassContainer(
                                borderRadius: 14,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.notifications_rounded,
                                    color: AppTheme.primaryColor,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // 概览卡片
                    SliverToBoxAdapter(
                      child: FadeSlideIn(
                        delay: const Duration(milliseconds: 100),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildOverviewCard(provider),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // 预算进度
                    SliverToBoxAdapter(
                      child: FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildBudgetCard(provider),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // AI 洞察
                    SliverToBoxAdapter(
                      child: FadeSlideIn(
                        delay: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildAiInsightCard(),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // 快速操作
                    SliverToBoxAdapter(
                      child: FadeSlideIn(
                        delay: const Duration(milliseconds: 400),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildQuickActions(),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // 最近交易标题
                    SliverToBoxAdapter(
                      child: FadeSlideIn(
                        delay: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '最近交易',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TransactionListScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  '查看全部',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),

                    // 最近交易列表
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: _buildRecentTransactions(provider),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(AppProvider provider) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  '今日消费',
                  provider.todaySpent,
                  Icons.today_rounded,
                  const Color(0xFFFF6B6B),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildOverviewItem(
                  '本月剩余',
                  provider.monthlyRemaining,
                  Icons.account_balance_wallet_rounded,
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.grey.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  '当前存款',
                  provider.currentSavings,
                  Icons.savings_rounded,
                  const Color(0xFF6BCB77),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildOverviewItem(
                  '月收入',
                  provider.monthlyIncome,
                  Icons.trending_up_rounded,
                  const Color(0xFF7C8CF8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(
      String label, double value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedCounter(
          value: value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(AppProvider provider) {
    final progress = provider.budgetUsagePercent;
    final isOverBudget = progress >= 1.0;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '本月预算',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? AppTheme.errorColor.withValues(alpha: 0.1)
                      : AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOverBudget ? '已超支' : '正常',
                  style: TextStyle(
                    color:
                        isOverBudget ? AppTheme.errorColor : AppTheme.successColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AnimatedProgressBar(
              progress: progress,
              height: 20,
              backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.2),
              valueColor:
                  isOverBudget ? AppTheme.errorColor : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已花费 ¥${provider.monthlySpent.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isOverBudget
                      ? AppTheme.errorColor
                      : AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '预算 ¥${provider.monthlyBudget.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.primaryLight.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日可用 ¥${provider.dailyAvailable.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiChatScreen()),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppTheme.primaryGradient,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI 洞察',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _aiInsight,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ScaleIn(
            delay: const Duration(milliseconds: 400),
            child: _buildQuickAction(
              '记一笔',
              Icons.add_circle_rounded,
              AppTheme.primaryColor,
              () => _navigateToAddTransaction(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ScaleIn(
            delay: const Duration(milliseconds: 500),
            child: _buildQuickAction(
              '预算',
              Icons.pie_chart_rounded,
              const Color(0xFF7C8CF8),
              () => _showBudgetDialog(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ScaleIn(
            delay: const Duration(milliseconds: 600),
            child: _buildQuickAction(
              '目标',
              Icons.flag_rounded,
              const Color(0xFFFFBE76),
              () => _navigateToGoals(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );
  }

  void _showBudgetDialog() {
    final provider = context.read<AppProvider>();
    final controller = TextEditingController(
      text: provider.monthlyBudget.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置月度预算'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '¥ ',
            hintText: '请输入月度预算',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                provider.setMonthlyBudget(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _navigateToGoals() {
    // Use a callback or navigate directly
    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('请切换到目标标签页')),
    );
  }

  Widget _buildRecentTransactions(AppProvider provider) {
    final recentTransactions = provider.transactions.take(5).toList();

    if (recentTransactions.isEmpty) {
      return SliverToBoxAdapter(
        child: GlassCard(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: AppTheme.textHint.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                '暂无交易记录',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '点击下方 + 开始记账',
                style: TextStyle(
                  color: AppTheme.textHint,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return FadeSlideIn(
            delay: Duration(milliseconds: 600 + (index * 100)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TransactionTile(
                transaction: recentTransactions[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTransactionScreen(
                        transaction: recentTransactions[index],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        childCount: recentTransactions.length,
      ),
    );
  }
}
