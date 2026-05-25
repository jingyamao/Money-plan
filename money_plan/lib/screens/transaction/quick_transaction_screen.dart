import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/transaction.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/animated_widgets.dart';

class QuickTransactionScreen extends StatelessWidget {
  const QuickTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFF0F4F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        '快捷记账',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(
                        child: const Text(
                          '常用支出',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 100),
                        child: _buildQuickExpenseGrid(context),
                      ),
                      const SizedBox(height: 24),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: const Text(
                          '常用收入',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 300),
                        child: _buildQuickIncomeGrid(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickExpenseGrid(BuildContext context) {
    final quickExpenses = [
      {'icon': Icons.restaurant_rounded, 'label': '餐饮', 'color': const Color(0xFFFF6B6B)},
      {'icon': Icons.directions_car_rounded, 'label': '交通', 'color': const Color(0xFF4ECDC4)},
      {'icon': Icons.shopping_bag_rounded, 'label': '购物', 'color': const Color(0xFFA78BFA)},
      {'icon': Icons.local_grocery_store_rounded, 'label': '超市', 'color': const Color(0xFFFFBE76)},
      {'icon': Icons.local_hospital_rounded, 'label': '医疗', 'color': const Color(0xFFFF8A80)},
      {'icon': Icons.school_rounded, 'label': '教育', 'color': const Color(0xFF7C8CF8)},
      {'icon': Icons.home_rounded, 'label': '生活', 'color': const Color(0xFF6BCB77)},
      {'icon': Icons.sports_esports_rounded, 'label': '娱乐', 'color': const Color(0xFFE040FB)},
      {'icon': Icons.local_cafe_rounded, 'label': '咖啡', 'color': const Color(0xFF795548)},
      {'icon': Icons.flight_rounded, 'label': '旅行', 'color': const Color(0xFF00BCD4)},
      {'icon': Icons.pets_rounded, 'label': '宠物', 'color': const Color(0xFFFF9800)},
      {'icon': Icons.more_horiz_rounded, 'label': '其他', 'color': const Color(0xFF95A5A6)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: quickExpenses.length,
      itemBuilder: (context, index) {
        final item = quickExpenses[index];
        return GestureDetector(
          onTap: () => _showAmountDialog(
            context,
            category: item['label'] as String,
            icon: item['icon'] as IconData,
            color: item['color'] as Color,
            isExpense: true,
          ),
          child: GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['label'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickIncomeGrid(BuildContext context) {
    final quickIncomes = [
      {'icon': Icons.work_rounded, 'label': '工资', 'color': const Color(0xFF6BCB77)},
      {'icon': Icons.card_giftcard_rounded, 'label': '奖金', 'color': const Color(0xFFFFBE76)},
      {'icon': Icons.attach_money_rounded, 'label': '报销', 'color': const Color(0xFF4ECDC4)},
      {'icon': Icons.trending_up_rounded, 'label': '投资', 'color': const Color(0xFF7C8CF8)},
      {'icon': Icons.more_horiz_rounded, 'label': '其他', 'color': const Color(0xFF95A5A6)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: quickIncomes.length,
      itemBuilder: (context, index) {
        final item = quickIncomes[index];
        return GestureDetector(
          onTap: () => _showAmountDialog(
            context,
            category: item['label'] as String,
            icon: item['icon'] as IconData,
            color: item['color'] as Color,
            isExpense: false,
          ),
          child: GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['label'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAmountDialog(
    BuildContext context, {
    required String category,
    required IconData icon,
    required Color color,
    required bool isExpense,
  }) {
    final amountController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(category),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                prefixText: '¥ ',
                hintText: '输入金额',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: '备注（可选）',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入有效金额')),
                );
                return;
              }

              final transaction = Transaction(
                id: const Uuid().v4(),
                amount: amount,
                type: isExpense
                    ? TransactionType.expense
                    : TransactionType.income,
                category: category,
                description: descController.text,
                transactionDate: DateTime.now(),
                source: TransactionSource.manual,
              );

              context.read<AppProvider>().addTransaction(transaction);
              Navigator.pop(context);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${isExpense ? "支出" : "收入"} ¥${amount.toStringAsFixed(2)}'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
