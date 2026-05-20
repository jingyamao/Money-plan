import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = '月';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 时间选择
                _buildPeriodSelector(),
                const SizedBox(height: 20),

                // 消费概览
                _buildSummaryCards(provider),
                const SizedBox(height: 20),

                // 分类饼图
                _buildCategoryPieChart(provider),
                const SizedBox(height: 20),

                // 每日趋势
                _buildDailyTrend(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['周', '月', '年'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    period,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(AppProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            '总支出',
            '¥${provider.monthlySpent.toStringAsFixed(2)}',
            Icons.arrow_downward,
            AppTheme.errorColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            '日均消费',
            '¥${(provider.monthlySpent / DateTime.now().day).toStringAsFixed(2)}',
            Icons.calendar_today,
            AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(AppProvider provider) {
    final breakdown = provider.categoryBreakdown;
    if (breakdown.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            '暂无消费数据',
            style: TextStyle(color: AppTheme.textHint),
          ),
        ),
      );
    }

    final total = breakdown.values.fold(0.0, (sum, v) => sum + v);
    final colors = [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      AppTheme.successColor,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '消费分类',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: breakdown.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final percent = (category.value / total * 100);
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: category.value,
                    title: '${percent.toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...breakdown.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(category.key)),
                  Text(
                    '¥${category.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailyTrend(AppProvider provider) {
    // 简化版趋势图，实际应该根据日期聚合数据
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '消费趋势',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 4),
                      const FlSpot(2, 3.5),
                      const FlSpot(3, 5),
                      const FlSpot(4, 4),
                      const FlSpot(5, 6),
                      const FlSpot(6, 5.5),
                    ],
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
