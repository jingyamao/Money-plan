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

  // 背景色 - 清新渐变
  static const Color scaffoldBg = Color(0xFFF0F4F8);
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF8FAFB);

  // 渐变色
  static const List<Color> primaryGradient = [
    Color(0xFF00BFA5),
    Color(0xFF00E5FF),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFFE8F5E9),
    Color(0xFFE0F7FA),
    Color(0xFFF1F8E9),
  ];

  // 文字颜色
  static const Color textPrimary = Color(0xFF1A2138);
  static const Color textSecondary = Color(0xFF6B7B8D);
  static const Color textHint = Color(0xFFADB5BD);

  // 分类颜色 - 更清新
  static const Map<String, Color> categoryColors = {
    '餐饮': Color(0xFFFF6B6B),
    '交通': Color(0xFF4ECDC4),
    '购物': Color(0xFFA78BFA),
    '娱乐': Color(0xFFFFBE76),
    '生活': Color(0xFF6BCB77),
    '医疗': Color(0xFFFF8A80),
    '教育': Color(0xFF7C8CF8),
    '其他': Color(0xFF95A5A6),
  };

  // 分类图标
  static const Map<String, IconData> categoryIcons = {
    '餐饮': Icons.restaurant_rounded,
    '交通': Icons.directions_car_rounded,
    '购物': Icons.shopping_bag_rounded,
    '娱乐': Icons.sports_esports_rounded,
    '生活': Icons.home_rounded,
    '医疗': Icons.local_hospital_rounded,
    '教育': Icons.school_rounded,
    '其他': Icons.more_horiz_rounded,
  };

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        selectedItemColor: primaryColor,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.withValues(alpha: 0.15),
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryColor,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        headerBackgroundColor: primaryColor,
        headerForegroundColor: Colors.white,
        dayStyle: const TextStyle(fontSize: 14),
        weekdayStyle: const TextStyle(
          fontSize: 13,
          color: textSecondary,
        ),
        yearStyle: const TextStyle(fontSize: 14),
      ),
    );
  }
}
