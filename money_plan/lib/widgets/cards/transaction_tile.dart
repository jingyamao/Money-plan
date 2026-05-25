import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/transaction.dart';
import '../../providers/app_provider.dart';
import '../common/glass_card.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? const Color(0xFFFF6B6B) : AppTheme.successColor;
    final categoryColor =
        AppTheme.categoryColors[transaction.category] ?? AppTheme.textSecondary;
    final categoryIcon =
        AppTheme.categoryIcons[transaction.category] ?? Icons.more_horiz_rounded;

    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _deleteTransaction(context),
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: '删除',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
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
                      DateFormat('MM/dd HH:mm')
                          .format(transaction.transactionDate),
                      style: const TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${isExpense ? '-' : '+'}¥${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteTransaction(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('确认删除'),
          ],
        ),
        content: Text(
          '确定要删除这笔${transaction.category}记录吗？',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().deleteTransaction(transaction.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已删除')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
