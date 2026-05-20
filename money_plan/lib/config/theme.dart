import 'package:flutter/material.dart';

class AppTheme {
  // 主色调 - 清新蓝绿
  static const Color primaryColor = Color(0xFF00BFA5);
  static const Color primaryLight = Color(0xFF64FFDA);
  static const Color primaryDark = Color(0xFF00897B);

  // 辅助色
  static const Color accentColor = Color(0xFF536DFE);
  static const Color warningColor = Color(0xFFFFAB00);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color successColor = Color(0xFF69F0AE);

  // 背景色
  static const Color scaffoldBg = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFFAFAFA);

  // 文字颜色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // 分类颜色
  static const Map<String, Color> categoryColors = {
    '餐饮': Color(0xFFFF7043),
    '交通': Color(0xFF42A5F5),
    '购物': Color(0xFFAB47BC),
    '娱乐': Color(0xFFFFCA28),
    '生活': Color(0xFF66BB6A),
    '医疗': Color(0xFFEF5350),
    '教育': Color(0xFF5C6BC0),
    '其他': Color(0xFF78909C),
  };

  // 分类图标
  static const Map<String, IconData> categoryIcons = {
    '餐饮': Icons.restaurant,
    '交通': Icons.directions_car,
    '购物': Icons.shopping_bag,
    '娱乐': Icons.sports_esports,
    '生活': Icons.home,
    '医疗': Icons.local_hospital,
    '教育': Icons.school,
    '其他': Icons.more_horiz,
  };

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
