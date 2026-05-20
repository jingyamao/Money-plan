import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 财务设置
              _buildSectionHeader('财务设置'),
              _buildSettingsCard(
                children: [
                  _buildSettingsTile(
                    icon: Icons.account_balance_wallet,
                    title: '月度预算',
                    subtitle: '¥${provider.monthlyBudget.toStringAsFixed(0)}',
                    onTap: () => _showBudgetDialog(context, provider),
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.savings,
                    title: '当前存款',
                    subtitle: '¥${provider.currentSavings.toStringAsFixed(0)}',
                    onTap: () => _showSavingsDialog(context, provider),
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.trending_up,
                    title: '月收入',
                    subtitle: '¥${provider.monthlyIncome.toStringAsFixed(0)}',
                    onTap: () => _showIncomeDialog(context, provider),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 数据管理
              _buildSectionHeader('数据管理'),
              _buildSettingsCard(
                children: [
                  _buildSettingsTile(
                    icon: Icons.cloud_upload,
                    title: '同步到云端',
                    subtitle: '数据将保存到 Supabase',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('功能开发中...')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.download,
                    title: '导入账单',
                    subtitle: '从支付宝/微信导入',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('功能开发中...')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.delete_outline,
                    title: '清除数据',
                    subtitle: '删除所有本地数据',
                    onTap: () => _showClearDataDialog(context),
                    textColor: AppTheme.errorColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 关于
              _buildSectionHeader('关于'),
              _buildSettingsCard(
                children: [
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: '版本',
                    subtitle: '1.0.0',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.favorite_border,
                    title: 'Money Plan',
                    subtitle: '你的智能理财助手',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? AppTheme.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: textColor ?? AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textHint),
      onTap: onTap,
    );
  }

  void _showBudgetDialog(BuildContext context, AppProvider provider) {
    final controller =
        TextEditingController(text: provider.monthlyBudget.toStringAsFixed(0));
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

  void _showSavingsDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(
        text: provider.currentSavings.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置当前存款'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '¥ ',
            hintText: '请输入当前存款',
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
              if (amount != null && amount >= 0) {
                provider.setCurrentSavings(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showIncomeDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(
        text: provider.monthlyIncome.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置月收入'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '¥ ',
            hintText: '请输入月收入',
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
              if (amount != null && amount >= 0) {
                provider.setMonthlyIncome(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('此操作将删除所有本地数据，无法恢复。确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );
  }
}
