import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/transaction.dart';
import '../../providers/app_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _selectedCategory = '餐饮';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记一笔'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 收入/支出切换
            _buildTypeToggle(),
            const SizedBox(height: 24),

            // 金额输入
            _buildAmountInput(),
            const SizedBox(height: 24),

            // 分类选择
            _buildCategorySelector(),
            const SizedBox(height: 24),

            // 日期选择
            _buildDateSelector(),
            const SizedBox(height: 16),

            // 备注
            _buildNoteInput(),
            const SizedBox(height: 32),

            // 保存按钮
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = TransactionType.expense),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _type == TransactionType.expense
                      ? AppTheme.errorColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '支出',
                    style: TextStyle(
                      color: _type == TransactionType.expense
                          ? Colors.white
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = TransactionType.income),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _type == TransactionType.income
                      ? AppTheme.successColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '收入',
                    style: TextStyle(
                      color: _type == TransactionType.income
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
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '金额',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '¥',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分类',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppTheme.categoryColors.entries.map((entry) {
            final isSelected = _selectedCategory == entry.key;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = entry.key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? entry.value.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? entry.value : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppTheme.categoryIcons[entry.key],
                      color: entry.value,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: isSelected ? entry.value : AppTheme.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              DateFormat('yyyy年MM月dd日').format(_selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 2,
        decoration: const InputDecoration(
          hintText: '添加备注...',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: _type == TransactionType.expense
              ? AppTheme.errorColor
              : AppTheme.successColor,
        ),
        child: const Text(
          '保存',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _saveTransaction() {
    final amountText = _amountController.text;
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入金额')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      type: _type,
      category: _selectedCategory,
      description: _noteController.text,
      transactionDate: _selectedDate,
      source: TransactionSource.manual,
    );

    context.read<AppProvider>().addTransaction(transaction);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('记账成功！')),
    );
  }
}
