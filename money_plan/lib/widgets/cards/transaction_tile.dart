import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? AppTheme.errorColor : AppTheme.successColor;
    final categoryColor =
        AppTheme.categoryColors[transaction.category] ?? AppTheme.textSecondary;
    final categoryIcon =
        AppTheme.categoryIcons[transaction.category] ?? Icons.more_horiz;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 分类图标
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (transaction.description != null &&
                    transaction.description!.isNotEmpty)
                  Text(
                    transaction.description!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  DateFormat('MM/dd HH:mm').format(transaction.transactionDate),
                  style: const TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // 金额
          Text(
            '${isExpense ? '-' : '+'}¥${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
