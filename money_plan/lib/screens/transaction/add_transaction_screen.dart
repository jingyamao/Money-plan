import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/transaction.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/animated_widgets.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _selectedCategory = '餐饮';
  DateTime _selectedDate = DateTime.now();
  late AnimationController _saveController;

  @override
  void initState() {
    super.initState();
    _saveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _saveController.dispose();
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
                        '记一笔',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                      const SizedBox(height: 32),

                      // Save button
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 500),
                        child: _buildSaveButton(),
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
                  boxShadow: _type == TransactionType.expense
                      ? [
                          BoxShadow(
                            color: AppTheme.errorColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '支出',
                    style: TextStyle(
                      color: _type == TransactionType.expense
                          ? Colors.white
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
                  boxShadow: _type == TransactionType.income
                      ? [
                          BoxShadow(
                            color: AppTheme.successColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '收入',
                    style: TextStyle(
                      color: _type == TransactionType.income
                          ? Colors.white
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '金额',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHint,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppTheme.categoryColors.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isSelected = _selectedCategory == category.key;

            return ScaleIn(
              delay: Duration(milliseconds: 100 + (index * 30)),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedCategory = category.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.value.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? category.value
                          : Colors.grey.withValues(alpha: 0.2),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppTheme.categoryIcons[category.key],
                        color: category.value,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.key,
                        style: TextStyle(
                          color: isSelected
                              ? category.value
                              : AppTheme.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
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
              style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
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

  Widget _buildSaveButton() {
    return GestureDetector(
      onTapDown: (_) => _saveController.forward(),
      onTapUp: (_) {
        _saveController.reverse();
        _saveTransaction();
      },
      onTapCancel: () => _saveController.reverse(),
      child: AnimatedBuilder(
        animation: _saveController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_saveController.value * 0.03),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _type == TransactionType.expense
                      ? [AppTheme.errorColor, const Color(0xFFFF8A80)]
                      : [AppTheme.successColor, const Color(0xFFB9F6CA)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (_type == TransactionType.expense
                            ? AppTheme.errorColor
                            : AppTheme.successColor)
                        .withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '保存',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
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
      SnackBar(
        content: const Text('记账成功！'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
