import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/savings_goal.dart';
import '../../providers/app_provider.dart';
import '../../services/ai_service.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('存款目标'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGoalDialog(context),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.savingsGoals.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.savingsGoals.length,
            itemBuilder: (context, index) {
              final goal = provider.savingsGoals[index];
              return _buildGoalCard(context, goal, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 80,
            color: AppTheme.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无存款目标',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右上角 + 创建第一个目标',
            style: TextStyle(
              color: AppTheme.textHint,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddGoalDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('创建目标'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
      BuildContext context, SavingsGoal goal, AppProvider provider) {
    final progress = goal.progress;
    final daysRemaining = goal.daysRemaining;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
                      ),
                    ),
                    if (daysRemaining > 0)
                      Text(
                        '剩余 $daysRemaining 天',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('编辑'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('删除', style: TextStyle(color: Colors.red)),
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

          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 12),

          // 金额信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '¥${goal.currentAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                '目标 ¥${goal.targetAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 进度百分比
          Text(
            '${(progress * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: progress >= 1 ? AppTheme.successColor : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (goal.targetDate != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: AiService().calculateGoalTimeline(
                goalAmount: goal.targetAmount,
                currentSavings: goal.currentAmount,
                monthlyIncome: provider.monthlyIncome,
                monthlyExpense: provider.monthlySpent,
              ),
              builder: (context, snapshot) {
                return Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
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
            return AlertDialog(
              title: const Text('创建存款目标'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    ListTile(
                      title: Text(
                        selectedDate != null
                            ? DateFormat('yyyy年MM月dd日').format(selectedDate!)
                            : '选择目标日期（可选）',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text;
                    final amount = double.tryParse(amountController.text);

                    if (name.isEmpty || amount == null || amount <= 0) {
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

                    context.read<AppProvider>().addSavingsGoal(goal);
                    Navigator.pop(context);
                  },
                  child: const Text('创建'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
