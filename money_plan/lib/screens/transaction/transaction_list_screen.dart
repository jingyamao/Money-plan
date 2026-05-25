import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/transaction.dart';
import '../../providers/app_provider.dart';
import '../../widgets/cards/transaction_tile.dart';
import 'edit_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _selectedFilter = '全部';
  DateTime? _startDate;
  DateTime? _endDate;

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
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        '全部交易',
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

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip('全部'),
                    const SizedBox(width: 8),
                    _buildFilterChip('支出'),
                    const SizedBox(width: 8),
                    _buildFilterChip('收入'),
                    const Spacer(),
                    GestureDetector(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.date_range_rounded,
                                size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              _startDate != null
                                  ? '${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}'
                                  : '筛选日期',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction list
              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    final transactions =
                        _filterTransactions(provider.transactions);

                    if (transactions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 48,
                                color: AppTheme.textHint.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text('暂无交易记录',
                                style: TextStyle(color: AppTheme.textSecondary)),
                          ],
                        ),
                      );
                    }

                    // Group by date
                    final grouped = _groupByDate(transactions);

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final date = grouped.keys.elementAt(index);
                        final dayTransactions = grouped[date]!;
                        final dayTotal = dayTransactions
                            .where((t) => t.type == TransactionType.expense)
                            .fold(0.0, (sum, t) => sum + t.amount);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '支出 ¥${dayTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...dayTransactions.map((t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TransactionTile(
                                    transaction: t,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditTransactionScreen(
                                                transaction: t),
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    var filtered = transactions;

    // Filter by type
    if (_selectedFilter == '支出') {
      filtered =
          filtered.where((t) => t.type == TransactionType.expense).toList();
    } else if (_selectedFilter == '收入') {
      filtered =
          filtered.where((t) => t.type == TransactionType.income).toList();
    }

    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((t) {
        return t.transactionDate.isAfter(_startDate!) &&
            t.transactionDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by date descending
    filtered.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return filtered;
  }

  Map<DateTime, List<Transaction>> _groupByDate(
      List<Transaction> transactions) {
    final Map<DateTime, List<Transaction>> grouped = {};
    for (final t in transactions) {
      final date = DateTime(
          t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(t);
    }
    return grouped;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return '今天';
    if (date == yesterday) return '昨天';
    return DateFormat('MM月dd日').format(date);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
}
