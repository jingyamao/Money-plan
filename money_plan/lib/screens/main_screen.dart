import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'transaction/add_transaction_screen.dart';
import 'statistics/statistics_screen.dart';
import 'goals/goals_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const SizedBox(), // 占位，中间按钮不对应页面
    const GoalsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 2) {
              // 中间按钮，打开记账页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddTransactionScreen(),
                ),
              );
            } else {
              setState(() => _currentIndex = index);
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '首页',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: '统计',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.savings_outlined),
              activeIcon: Icon(Icons.savings),
              label: '目标',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
