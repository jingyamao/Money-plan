import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/transaction.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/animated_widgets.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final StorageService _storage = StorageService();
  bool _isImporting = false;
  String _status = '';

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
                      child: Text('导入账单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(
                        child: _buildInfoCard(),
                      ),
                      const SizedBox(height: 20),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 100),
                        child: _buildImportOption(
                          title: '支付宝账单导入',
                          description: '支持支付宝导出的 CSV 格式账单',
                          icon: Icons.payment_rounded,
                          color: const Color(0xFF1677FF),
                          onTap: () => _showImportGuide('alipay'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: _buildImportOption(
                          title: '微信账单导入',
                          description: '支持微信导出的 CSV 格式账单',
                          icon: Icons.chat_bubble_rounded,
                          color: const Color(0xFF07C160),
                          onTap: () => _showImportGuide('wechat'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_isImporting) _buildImportingIndicator(),
                      if (_status.isNotEmpty) _buildStatusCard(),
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '导入说明',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '从支付宝或微信导出 CSV 格式账单，然后在此处导入。导入后会自动识别收支类型和分类。',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportOption({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textHint, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImportingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(_status, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppTheme.successColor),
          const SizedBox(width: 12),
          Expanded(child: Text(_status, style: TextStyle(color: AppTheme.successColor))),
        ],
      ),
    );
  }

  void _showImportGuide(String type) {
    final typeName = type == 'alipay' ? '支付宝' : '微信';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('导入${typeName}账单'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('操作步骤：', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
              const SizedBox(height: 12),
              if (type == 'alipay') ...[
                _buildStep('1', '打开支付宝 APP'),
                _buildStep('2', '进入「我的」→「账单」'),
                _buildStep('3', '点击右上角「...」→「开具交易流水证明」'),
                _buildStep('4', '选择时间范围，导出 CSV 文件'),
                _buildStep('5', '将文件发送到电脑，点击下方按钮导入'),
              ] else ...[
                _buildStep('1', '打开微信 APP'),
                _buildStep('2', '进入「我」→「服务」→「钱包」'),
                _buildStep('3', '点击「账单」→ 右上角「常见问题」'),
                _buildStep('4', '选择「下载账单」→「用于个人对账」'),
                _buildStep('5', '选择时间范围，导出 CSV 文件'),
                _buildStep('6', '将文件发送到电脑，点击下方按钮导入'),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: AppTheme.warningColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '注意：请确保 CSV 文件编码为 UTF-8',
                        style: TextStyle(fontSize: 12, color: AppTheme.warningColor),
                      ),
                    ),
                  ],
                ),
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
              Navigator.pop(context);
              _simulateImport(type);
            },
            child: const Text('开始导入'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Future<void> _simulateImport(String type) async {
    setState(() {
      _isImporting = true;
      _status = '正在解析账单文件...';
    });

    // 模拟导入过程
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _status = '正在导入交易记录...';
    });

    await Future.delayed(const Duration(seconds: 1));

    // 创建示例导入数据
    final now = DateTime.now();
    final sampleTransactions = [
      Transaction(
        id: const Uuid().v4(),
        amount: 35.0,
        type: TransactionType.expense,
        category: '餐饮',
        description: '导入：午餐',
        transactionDate: now.subtract(const Duration(days: 1)),
        source: type == 'alipay' ? TransactionSource.alipay : TransactionSource.wechat,
      ),
      Transaction(
        id: const Uuid().v4(),
        amount: 128.0,
        type: TransactionType.expense,
        category: '购物',
        description: '导入：日用品',
        transactionDate: now.subtract(const Duration(days: 2)),
        source: type == 'alipay' ? TransactionSource.alipay : TransactionSource.wechat,
      ),
    ];

    for (final t in sampleTransactions) {
      await _storage.addTransaction(t);
    }

    setState(() {
      _isImporting = false;
      _status = '成功导入 ${sampleTransactions.length} 条记录';
    });
  }
}
