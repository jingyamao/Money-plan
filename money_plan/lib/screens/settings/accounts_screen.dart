import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/account.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/animated_widgets.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final StorageService _storage = StorageService();
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() {
    setState(() {
      _accounts = _storage.getAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F7FA), Color(0xFFF0F4F8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text('账户管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: AppTheme.primaryColor),
                      onPressed: _showAddDialog,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_accounts.isEmpty)
                        FadeSlideIn(child: _buildEmptyState())
                      else
                        ..._accounts.asMap().entries.map((entry) {
                          return FadeSlideIn(
                            delay: Duration(milliseconds: entry.key * 50),
                            child: _buildAccountItem(entry.value),
                          );
                        }),
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

  Widget _buildAccountItem(Account account) {
    final iconData = _getAccountIcon(account.type);
    final color = _getAccountColor(account.type);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(_getAccountTypeName(account.type), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _deleteAccount(account),
            child: Icon(Icons.delete_outline_rounded, color: AppTheme.textHint, size: 20),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_wallet_rounded, size: 48, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          const Text('暂无账户', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('添加你的记账账户', style: TextStyle(color: AppTheme.textHint)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('添加账户'),
          ),
        ],
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'alipay': return Icons.payment_rounded;
      case 'wechat': return Icons.chat_bubble_rounded;
      case 'cash': return Icons.money_rounded;
      default: return Icons.account_balance_wallet_rounded;
    }
  }

  Color _getAccountColor(String type) {
    switch (type) {
      case 'alipay': return const Color(0xFF1677FF);
      case 'wechat': return const Color(0xFF07C160);
      case 'cash': return const Color(0xFFFFBE76);
      default: return AppTheme.primaryColor;
    }
  }

  String _getAccountTypeName(String type) {
    switch (type) {
      case 'alipay': return '支付宝';
      case 'wechat': return '微信';
      case 'cash': return '现金';
      default: return '其他';
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    String selectedType = 'alipay';

    final types = [
      {'value': 'alipay', 'label': '支付宝', 'icon': Icons.payment_rounded, 'color': const Color(0xFF1677FF)},
      {'value': 'wechat', 'label': '微信', 'icon': Icons.chat_bubble_rounded, 'color': const Color(0xFF07C160)},
      {'value': 'cash', 'label': '现金', 'icon': Icons.money_rounded, 'color': const Color(0xFFFFBE76)},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('添加账户'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('账户类型', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: types.map((t) {
                        final isSelected = selectedType == t['value'];
                        return GestureDetector(
                          onTap: () => setState(() => selectedType = t['value'] as String),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? (t['color'] as Color).withValues(alpha: 0.1) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? t['color'] as Color : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(t['icon'] as IconData, size: 18, color: t['color'] as Color),
                                const SizedBox(width: 8),
                                Text(t['label'] as String, style: TextStyle(
                                  color: isSelected ? t['color'] as Color : AppTheme.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                )),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '账户名称',
                        hintText: '如：我的支付宝',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text;
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入账户名称')));
                      return;
                    }

                    final account = Account(
                      id: const Uuid().v4(),
                      name: name,
                      type: selectedType,
                    );

                    _storage.saveAccount(account);
                    _loadAccounts();
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

  void _deleteAccount(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除账户"${account.name}"吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              _storage.deleteAccount(account.id);
              _loadAccounts();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
