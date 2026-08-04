import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF0F766E);
  static const accent = Color(0xFFF97066);
  static const background = Color(0xFFFAF9F6);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const border = Color(0xFFE9E5DD);
  static const softTeal = Color(0xFFE4F2EF);
  static const softCoral = Color(0xFFFFE9E5);
  static const softGold = Color(0xFFFFF4DE);
}

abstract final class AppSpace {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const xxl = 36.0;
}

abstract final class AppRadii {
  static const card = BorderRadius.all(Radius.circular(16));
  static const pill = BorderRadius.all(Radius.circular(99));
  static const input = BorderRadius.all(Radius.circular(12));
}

abstract final class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x120F766E), blurRadius: 18, offset: Offset(0, 6)),
  ];
}

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
    error: AppColors.accent,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      height: 1.28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      height: 1.28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      height: 1.33,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.43,
      color: AppColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      height: 1.33,
      color: AppColors.textSecondary,
    ),
  ),
);
