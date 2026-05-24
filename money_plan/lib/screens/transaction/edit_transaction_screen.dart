import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/transaction.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/animated_widgets.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TransactionType _type;
  late String _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(
      text: widget.transaction.description ?? '',
    );
    _type = widget.transaction.type;
    _selectedCategory = widget.transaction.category;
    _selectedDate = widget.transaction.transactionDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

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
              // Top bar
              FadeSlideIn(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        '编辑记录',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: _saveTransaction,
                        child: const Text(
                          '保存',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      // Type toggle
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 50),
                        child: _buildTypeToggle(),
                      ),
                      const SizedBox(height: 24),

                      // Amount
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 100),
                        child: _buildAmountInput(),
                      ),
                      const SizedBox(height: 24),

                      // Category
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: _buildCategorySelector(),
                      ),
                      const SizedBox(height: 24),

                      // Date
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 300),
                        child: _buildDateSelector(),
                      ),
                      const SizedBox(height: 16),

                      // Note
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 400),
                        child: _buildNoteInput(),
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

  Widget _buildTypeToggle() {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = TransactionType.expense),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _type == TransactionType.expense
                      ? AppTheme.errorColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _type == TransactionType.income
                      ? AppTheme.successColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
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
    return GlassCard(
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '¥',
                style: TextStyle(
                  fontSize: 36,
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
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
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
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppTheme.categoryColors.entries.map((entry) {
            final isSelected = _selectedCategory == entry.key;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? entry.value.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? entry.value
                        : Colors.grey.withValues(alpha: 0.2),
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
                        color:
                            isSelected ? entry.value : AppTheme.textPrimary,
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
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              DateFormat('yyyy年MM月dd日').format(_selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFBE76).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_note_rounded,
                color: Color(0xFFFFBE76), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: '添加备注...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
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

    final updatedTransaction = widget.transaction.copyWith(
      amount: amount,
      type: _type,
      category: _selectedCategory,
      description: _noteController.text,
      transactionDate: _selectedDate,
    );

    context.read<AppProvider>().updateTransaction(updatedTransaction);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已更新'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
