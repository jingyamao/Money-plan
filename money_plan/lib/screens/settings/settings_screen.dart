import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/animated_widgets.dart';
import 'fixed_transactions_screen.dart';
import 'category_budget_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8EAF6),
              Color(0xFFF0F4F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, child) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: FadeSlideIn(
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Text(
                          '设置',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // 财务设置
                  SliverToBoxAdapter(
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSectionHeader('财务设置'),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSettingsCard(
                          children: [
                            _buildSettingsTile(
                              icon: Icons.account_balance_wallet_rounded,
                              iconColor: const Color(0xFF7C8CF8),
                              title: '月度预算',
                              subtitle:
                                  '¥${provider.monthlyBudget.toStringAsFixed(0)}',
                              onTap: () =>
                                  _showBudgetDialog(context, provider),
                            ),
                            Divider(
                                height: 1,
                                color: Colors.grey.withValues(alpha: 0.15)),
                            _buildSettingsTile(
                              icon: Icons.pie_chart_rounded,
                              iconColor: const Color(0xFFFFBE76),
                              title: '分类预算',
                              subtitle: '按类别设置消费预算',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const CategoryBudgetScreen(),
                                  ),
                                );
                              },
                            ),
                            Divider(
                                height: 1,
                                color: Colors.grey.withValues(alpha: 0.15)),
                            _buildSettingsTile(
                              icon: Icons.savings_rounded,
                              iconColor: const Color(0xFF6BCB77),
                              title: '当前存款',
                              subtitle:
                                  '¥${provider.currentSavings.toStringAsFixed(0)}',
                              onTap: () =>
                                  _showSavingsDialog(context, provider),
                            ),
                            Divider(
                                height: 1,
                                color: Colors.grey.withValues(alpha: 0.15)),
                            _buildSettingsTile(
                              icon: Icons.trending_up_rounded,
                              iconColor: AppTheme.primaryColor,
                              title: '月收入',
                              subtitle:
                                  '¥${provider.monthlyIncome.toStringAsFixed(0)}',
                              onTap: () =>
                                  _showIncomeDialog(context, provider),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // 数据管理
                  SliverToBoxAdapter(
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSectionHeader('数据管理'),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 250),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSettingsCard(
                          children: [
                            _buildSettingsTile(
                              icon: Icons.repeat_rounded,
                              iconColor: const Color(0xFF7C8CF8),
                              title: '固定收支',
                              subtitle: '管理每月固定收入和支出',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const FixedTransactionsScreen(),
                                  ),
                                );
                              },
                            ),
                            Divider(
                                height: 1,
                                color: Colors.grey.withValues(alpha: 0.15)),
                            _buildSettingsTile(
                              icon: Icons.cloud_upload_rounded,
                              iconColor: const Color(0xFF4ECDC4),
                              title: '同步到云端',
                              subtitle: '数据将保存到 Supabase',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  _buildSnackBar('功能开发中...'),
                                );
                              },
                            ),
                            Divider(
                                height: 1,
                                color: Colors.grey.withValues(alpha: 0.15)),
                            _buildSettingsTile(
                              icon: Icons.download_rounded,
                              iconColor: const Color(0xFFFFBE76),
                              title: '导入账单',
                              subtitle: '从支付宝/微信导入',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  _buildSnackBar('功能开发中...'),
                                );
                              },
                            ),
                            Divider(
                                height: 1,
                                color: Colors.grey.withValues(alpha: 0.15)),
                            _buildSettingsTile(
                              icon: Icons.delete_outline_rounded,
                              iconColor: AppTheme.errorColor,
                              title: '清除数据',
                              subtitle: '删除所有本地数据',
                              onTap: () => _showClearDataDialog(context),
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // 关于
                  SliverToBoxAdapter(
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSectionHeader('关于'),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 350),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSettingsCard(
                          children: [
                            _buildSettingsTile(
                              icon: Icons.info_outline_rounded,
                              iconColor: AppTheme.textSecondary,
                              title: '版本',
                              subtitle: '1.0.0',
                              onTap: () {},
                            ),
                            Divider(
                                height: 1,
                                color: Colors.grey.withValues(alpha: 0.15)),
                            _buildSettingsTile(
                              icon: Icons.favorite_rounded,
                              iconColor: const Color(0xFFFF6B6B),
                              title: 'Money Plan',
                              subtitle: '你的智能理财助手',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  SnackBar _buildSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? AppTheme.errorColor
                            : AppTheme.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textHint, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(
        text: provider.monthlyBudget.toStringAsFixed(0));
    _showInputDialog(
      context,
      title: '设置月度预算',
      controller: controller,
      prefix: '¥ ',
      onSave: (value) {
        if (value > 0) provider.setMonthlyBudget(value);
      },
    );
  }

  void _showSavingsDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(
        text: provider.currentSavings.toStringAsFixed(0));
    _showInputDialog(
      context,
      title: '设置当前存款',
      controller: controller,
      prefix: '¥ ',
      onSave: (value) {
        if (value >= 0) provider.setCurrentSavings(value);
      },
    );
  }

  void _showIncomeDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(
        text: provider.monthlyIncome.toStringAsFixed(0));
    _showInputDialog(
      context,
      title: '设置月收入',
      controller: controller,
      prefix: '¥ ',
      onSave: (value) {
        if (value >= 0) provider.setMonthlyIncome(value);
      },
    );
  }

  void _showInputDialog(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required String prefix,
    required Function(double) onSave,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  prefixText: prefix,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(controller.text);
                        if (amount != null) {
                          onSave(amount);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppTheme.errorColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '确认清除',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '此操作将删除所有本地数据，无法恢复。',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('功能开发中...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                      child: const Text('确认清除'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
