import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/fixed_transaction.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/animated_widgets.dart';

class FixedTransactionsScreen extends StatefulWidget {
  const FixedTransactionsScreen({super.key});

  @override
  State<FixedTransactionsScreen> createState() =>
      _FixedTransactionsScreenState();
}

class _FixedTransactionsScreenState extends State<FixedTransactionsScreen> {
  final StorageService _storage = StorageService();
  List<FixedTransaction> _fixedTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadFixedTransactions();
  }

  void _loadFixedTransactions() {
    setState(() {
      _fixedTransactions = _storage.getFixedTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenses =
        _fixedTransactions.where((t) => t.type == FixedType.expense).toList();
    final incomes =
        _fixedTransactions.where((t) => t.type == FixedType.income).toList();

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
                        '固定收支',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded,
                          color: AppTheme.primaryColor),
                      onPressed: _showAddDialog,
                    ),
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
                      if (expenses.isNotEmpty) ...[
                        FadeSlideIn(
                          child: _buildSectionHeader('固定支出', expenses),
                        ),
                        const SizedBox(height: 12),
                        ...expenses.asMap().entries.map((entry) {
                          return FadeSlideIn(
                            delay: Duration(milliseconds: 100 + (entry.key * 50)),
                            child: _buildFixedItem(entry.value),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],
                      if (incomes.isNotEmpty) ...[
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 200),
                          child: _buildSectionHeader('固定收入', incomes),
                        ),
                        const SizedBox(height: 12),
                        ...incomes.asMap().entries.map((entry) {
                          return FadeSlideIn(
                            delay: Duration(milliseconds: 300 + (entry.key * 50)),
                            child: _buildFixedItem(entry.value),
                          );
                        }),
                      ],
                      if (_fixedTransactions.isEmpty)
                        FadeSlideIn(
                          child: _buildEmptyState(),
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

  Widget _buildSectionHeader(String title, List<FixedTransaction> items) {
    final total = items.fold(0.0, (sum, t) => sum + t.amount);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          '¥${total.toStringAsFixed(0)}/月',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFixedItem(FixedTransaction item) {
    final color = item.type == FixedType.expense
        ? const Color(0xFFFF6B6B)
        : AppTheme.successColor;
    final categoryColor =
        AppTheme.categoryColors[item.category] ?? AppTheme.textSecondary;
    final categoryIcon =
        AppTheme.categoryIcons[item.category] ?? Icons.more_horiz_rounded;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(categoryIcon, color: categoryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '每月${item.dayOfMonth}号',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.category,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.type == FixedType.expense ? "-" : "+"}¥${item.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _deleteFixedTransaction(item),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.textHint,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.repeat_rounded,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '暂无固定收支',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '添加每月固定的收入和支出\n如：房租、工资、水电费',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textHint,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('添加固定收支'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    FixedType type = FixedType.expense;
    String category = '生活';
    int selectedDay = 1;

    // 根据类型设置默认分类
    final expenseCategories = ['生活', '住房', '交通', '餐饮', '其他'];
    final incomeCategories = ['工资', '奖金', '投资', '其他'];

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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '添加固定收支',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Type toggle
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  type = FixedType.expense;
                                  category = expenseCategories.first;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: type == FixedType.expense
                                      ? AppTheme.errorColor
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '支出',
                                    style: TextStyle(
                                      color: type == FixedType.expense
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  type = FixedType.income;
                                  category = incomeCategories.first;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: type == FixedType.income
                                      ? AppTheme.successColor
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '收入',
                                    style: TextStyle(
                                      color: type == FixedType.income
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Name
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: '名称',
                          hintText: type == FixedType.expense
                              ? '如：房租、水电费'
                              : '如：工资、奖金',
                          prefixIcon: Icon(
                            type == FixedType.expense
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: type == FixedType.expense
                                ? AppTheme.errorColor
                                : AppTheme.successColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Amount
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '金额',
                          prefixText: '¥ ',
                          prefixStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Category
                      const Text(
                        '分类',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (type == FixedType.expense
                                ? expenseCategories
                                : incomeCategories)
                            .map((c) {
                          final isSelected = category == c;
                          final color = AppTheme.categoryColors[c] ??
                              AppTheme.textSecondary;
                          return GestureDetector(
                            onTap: () => setState(() => category = c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withValues(alpha: 0.15)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  color: isSelected
                                      ? color
                                      : AppTheme.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Day of month
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 18, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            const Text(
                              '每月',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: selectedDay,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                items: List.generate(
                                  28,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('${i + 1}号'),
                                  ),
                                ),
                                onChanged: (v) =>
                                    setState(() => selectedDay = v!),
                              ),
                            ),
                            const Text('执行'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
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

                                final fixed = FixedTransaction(
                                  id: const Uuid().v4(),
                                  name: name,
                                  amount: amount,
                                  type: type,
                                  category: category,
                                  dayOfMonth: selectedDay,
                                );

                                _storage.saveFixedTransaction(fixed);
                                _loadFixedTransactions();
                                Navigator.pop(context);
                              },
                              child: const Text('添加'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteFixedTransaction(FixedTransaction item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
        content: Text('确定要删除固定收支"${item.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              _storage.deleteFixedTransaction(item.id);
              _loadFixedTransactions();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
