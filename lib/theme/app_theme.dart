import 'package:flutter/material.dart';

class AppTheme {
  // 主色调 - 使用深蓝色作为基础
  static const primaryColor = Color(0xFF0A84FF);
  // 强调色 - 科技感紫色
  static const accentColor = Color(0xFF6E3AFF);
  // 背景色 - 深色渐变
  static const backgroundColor = Color(0xFF1A1B1E);
  // 卡片背景色
  static const cardColor = Color(0xFF2A2B2E);
  // 次要文本颜色
  static const secondaryTextColor = Color(0xFF8E8E93);

  // 定义渐变色
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A84FF),
      Color(0xFF6E3AFF),
    ],
  );

  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
} 