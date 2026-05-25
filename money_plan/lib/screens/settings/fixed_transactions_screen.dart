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

    return GlassCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.type == FixedType.expense
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '每月${item.dayOfMonth}号 · ${item.category}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.type == FixedType.expense ? "-" : "+"}¥${item.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteFixedTransaction(item),
            child: Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.textHint,
              size: 20,
            ),
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
          Icon(
            Icons.repeat_rounded,
            size: 64,
            color: AppTheme.textHint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无固定收支',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '添加每月固定的收入和支出',
            style: TextStyle(
              color: AppTheme.textHint,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('添加固定收支'),
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

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('添加固定收支'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => type = FixedType.expense),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: type == FixedType.expense
                                    ? AppTheme.errorColor
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => type = FixedType.income),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: type == FixedType.income
                                    ? AppTheme.successColor
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '名称',
                        hintText: '如：房租、工资',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '金额',
                        prefixText: '¥ ',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Category
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: '分类'),
                      items: ['生活', '住房', '交通', '餐饮', '工资', '其他']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => category = v!),
                    ),
                    const SizedBox(height: 12),
                    // Day of month
                    Row(
                      children: [
                        const Text('每月'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: selectedDay,
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
              ],
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
        title: const Text('确认删除'),
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
