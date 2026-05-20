import 'package:flutter/material.dart';
import '../../config/theme.dart';

class BudgetCard extends StatelessWidget {
  final double budget;
  final double spent;
  final double dailyAvailable;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.dailyAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > budget;

    return Container(
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
              const Text(
                '本月预算',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? AppTheme.errorColor.withOpacity(0.1)
                      : AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOverBudget ? '已超支' : '正常',
                  style: TextStyle(
                    color: isOverBudget ? AppTheme.errorColor : AppTheme.successColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 进度条
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 20,
                  backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget ? AppTheme.errorColor : AppTheme.primaryColor,
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 金额详情
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAmountItem('已花费', spent, AppTheme.errorColor),
              _buildAmountItem('预算', budget, AppTheme.textPrimary),
            ],
          ),
          const SizedBox(height: 12),

          // 日均可用
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日可用: ¥${dailyAvailable.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
