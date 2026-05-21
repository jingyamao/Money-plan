import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/savings_goal.dart';
import '../../providers/app_provider.dart';
import '../../services/ai_service.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/animated_widgets.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8E1),
              Color(0xFFE8F5E9),
              Color(0xFFF0F4F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, child) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
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
                                const Text(
                                  '存款目标',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${provider.savingsGoals.length} 个目标进行中',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            GlassContainer(
                              borderRadius: 14,
                              child: IconButton(
                                icon: const Icon(Icons.add_rounded,
                                    color: AppTheme.primaryColor),
                                onPressed: () =>
                                    _showAddGoalDialog(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  if (provider.savingsGoals.isEmpty)
                    SliverToBoxAdapter(
                      child: FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: _buildEmptyState(context),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return FadeSlideIn(
                              delay: Duration(milliseconds: 200 + (index * 100)),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildGoalCard(
                                    context,
                                    provider.savingsGoals[index],
                                    provider),
                              ),
                            );
                          },
                          childCount: provider.savingsGoals.length,
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

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: GlassCard(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFBE76).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_rounded,
                size: 48,
                color: Color(0xFFFFBE76),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '暂无存款目标',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '设定一个目标，开始为梦想存钱',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddGoalDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('创建目标'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(
      BuildContext context, SavingsGoal goal, AppProvider provider) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (goal.daysRemaining > 0)
                      Text(
                        '剩余 ${goal.daysRemaining} 天',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_horiz_rounded,
                    color: AppTheme.textHint),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            color: AppTheme.errorColor, size: 20),
                        SizedBox(width: 8),
                        Text('删除', style: TextStyle(color: AppTheme.errorColor)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    provider.deleteSavingsGoal(goal.id);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AnimatedProgressBar(
              progress: goal.progress,
              height: 16,
              valueColor: const Color(0xFF6BCB77),
            ),
          ),
          const SizedBox(height: 14),

          // Amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedCounter(
                value: goal.currentAmount,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                '目标 ¥${goal.targetAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress percentage
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: goal.progress >= 1.0
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(goal.progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: goal.progress >= 1.0
                        ? AppTheme.successColor
                        : AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          if (goal.targetDate != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.05),
                    AppTheme.primaryLight.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FutureBuilder<String>(
                future: AiService().calculateGoalTimeline(
                  goalAmount: goal.targetAmount,
                  currentSavings: goal.currentAmount,
                  monthlyIncome: provider.monthlyIncome,
                  monthlyExpense: provider.monthlySpent,
                ),
                builder: (context, snapshot) {
                  return Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 18, color: AppTheme.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          snapshot.data ?? '计算中...',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '创建存款目标',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '目标名称',
                        hintText: '如：买车、旅行',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: '目标金额',
                        prefixText: '¥ ',
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 3650)),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate != null
                                  ? DateFormat('yyyy年MM月dd日')
                                      .format(selectedDate!)
                                  : '选择目标日期（可选）',
                              style: TextStyle(
                                color: selectedDate != null
                                    ? AppTheme.textPrimary
                                    : AppTheme.textHint,
                              ),
                            ),
                          ],
                        ),
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
                              final name = nameController.text;
                              final amount =
                                  double.tryParse(amountController.text);

                              if (name.isEmpty ||
                                  amount == null ||
                                  amount <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('请填写完整信息')),
                                );
                                return;
                              }

                              final goal = SavingsGoal(
                                id: const Uuid().v4(),
                                name: name,
                                targetAmount: amount,
                                targetDate: selectedDate,
                              );

                              context
                                  .read<AppProvider>()
                                  .addSavingsGoal(goal);
                              Navigator.pop(context);
                            },
                            child: const Text('创建'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
