/// App 主題設定 - 深色極簡風格
import 'package:flutter/material.dart';

class AppTheme {
  // ---------- 深色主題（保留原本常數） ----------
  // 主色調（深色主題）
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF242424);
  static const Color border = Color(0xFF2E2E2E);

  static const Color primary = Color(0xFFFF6B35);   // 橘紅 - 行動力
  static const Color secondary = Color(0xFF4ECDC4); // 青綠 - 創意
  static const Color danger = Color(0xFFFF4444);    // 紅 - 魔鬼審計

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF555555);

  // ---------- 明亮主題 色彩常數（來自設計稿） ----------
  // Core Backgrounds
  static const Color backgroundLight = Color(0xFFFAF8F5); // 溫暖的米白色作為主背景
  static const Color surfaceLight = Color(0xFFFFFFFF); // 純白色卡片
  static const Color surfaceMutedLight = Color(0xFFF5F3F0); // 柔和的灰米色

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1C1C1C); // 深灰色標題
  static const Color textSecondaryLight = Color(0xFF6B6B6B); // 中灰色描述文字
  static const Color textMutedLight = Color(0xFF9A9A9A); // 淡灰色次要文字

  // Border Colors
  static const Color borderLight = Color(0xFFE8E5E0); // 預設邊框
  static const Color borderStrongLight = Color(0xFFD4D0C8); // 強調邊框

  // Accent Colors
  static const Color primaryLight = Color(0xFF1E3A5F); // 深海軍藍(主要強調色)
  static const Color primaryTintLight = Color(0x261E3A5F); // 15% 透明度的海軍藍
  static const Color secondaryLight = Color(0xFF3D6B4F); // 成功狀態綠色
  static const Color dangerLight = Color(0xFF8B4049); // 錯誤狀態紅色

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          background: background,
          surface: surface,
          primary: primary,
          secondary: secondary,
          onBackground: textPrimary,
          onSurface: textPrimary,
          onPrimary: Colors.white,
        ),
        cardTheme: CardTheme(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: border, width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
          ),
          titleLarge: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          titleMedium: TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: textPrimary,
            fontSize: 16,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            color: textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
          labelSmall: TextStyle(
            color: textMuted,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textPrimary,
            side: const BorderSide(color: border),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: border,
          thickness: 1,
        ),
      );

  // 明亮、簡約、現代風格主題
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        // 全局 scaffold 背景
        scaffoldBackgroundColor: backgroundLight,
        // ColorScheme 使用 Material 的 light 基底，並注入設計稿色彩
        colorScheme: const ColorScheme.light(
          background: backgroundLight,
          surface: surfaceLight,
          primary: primaryLight,
          onPrimary: Colors.white,
          secondary: secondaryLight,
          onBackground: textPrimaryLight,
          onSurface: textPrimaryLight,
          error: dangerLight,
        ),

        // 卡片樣式：寬鬆留白、柔和圓角、細邊框
        cardTheme: CardTheme(
          color: surfaceLight,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 卡片圓角 16px
            side: const BorderSide(color: borderLight, width: 1),
          ),
        ),

        // AppBar：透明或與背景接近，扁平化處理
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundLight,
          foregroundColor: textPrimaryLight,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            color: textPrimaryLight,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: textPrimaryLight),
        ),

        // TextTheme：根據設計稿的字型系統
        textTheme: const TextTheme(
          // 大標題
          displayLarge: TextStyle(
            fontFamily: 'Inter',
            color: textPrimaryLight,
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
          ),
          // 卡片標題
          titleLarge: TextStyle(
            fontFamily: 'Inter',
            color: textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
          // 正文（大）
          bodyLarge: TextStyle(
            fontFamily: 'Inter',
            color: textPrimaryLight,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
          // 正文（常用）
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            color: textSecondaryLight,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          // 標籤 / 次要文字
          labelSmall: TextStyle(
            fontFamily: 'Inter',
            color: textMutedLight,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          // 按鈕文字樣式（供 ElevatedButton 使用）
          titleMedium: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        // ElevatedButton：主要 CTAs，圓角 12px，高度 52px
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryLight,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52), // 按鈕高度 52px
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 按鈕圓角 12px
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
            elevation: 0,
          ),
        ),

        // OutlinedButton：次要操作，保留細邊框
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryLight,
            side: const BorderSide(color: borderStrongLight),
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Divider：使用淺色邊框
        dividerTheme: const DividerThemeData(
          color: borderLight,
          thickness: 1,
          space: 1,
        ),

        // Global visual density & component defaults
        visualDensity: VisualDensity.adaptivePlatformDensity,

        // Default icon theme
        iconTheme: const IconThemeData(color: textPrimaryLight),
      );
}
