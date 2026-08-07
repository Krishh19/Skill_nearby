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
    BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 4), spreadRadius: 0),
    BoxShadow(color: Color(0x080F766E), blurRadius: 20, offset: Offset(0, 8), spreadRadius: -2),
  ];
  static const elevated = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6), spreadRadius: 0),
    BoxShadow(color: Color(0x100F766E), blurRadius: 28, offset: Offset(0, 12), spreadRadius: -2),
  ];
}

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
    error: AppColors.accent,
    onPrimary: Colors.white,
    onSurface: AppColors.textPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.textPrimary,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
  ),
  cardTheme: const CardThemeData(
    color: AppColors.surface,
    elevation: 0,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.border,
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
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: AppRadii.input,
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadii.input,
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadii.input,
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
  ),
);

abstract final class DarkColors {
  static const bg = Color(0xFF0F1513);
  static const bgRaised = Color(0xFF171F1C);
  static const surface = Color(0xFF1D2622);
  static const surface2 = Color(0xFF23302A);
  static const teal = Color(0xFF4FC3AE);
  static const tealDeep = Color(0xFF3AA890);
  static const coral = Color(0xFFF2895F);
  static const ink = Color(0xFFF1EEE3);
  static const stone = Color(0xFF9BA6A0);
  static const line = Color(0xFF2B3733);
}

ThemeData appDarkTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: DarkColors.bg,
  colorScheme: const ColorScheme.dark(
    primary: DarkColors.teal,
    secondary: DarkColors.coral,
    surface: DarkColors.surface,
    error: DarkColors.coral,
    onPrimary: Color(0xFF0B1B17),
    onSurface: DarkColors.ink,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: DarkColors.bg,
    foregroundColor: DarkColors.ink,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
  ),
  cardTheme: const CardThemeData(
    color: DarkColors.surface,
    elevation: 0,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: DarkColors.surface,
    surfaceTintColor: Colors.transparent,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: DarkColors.surface,
    surfaceTintColor: Colors.transparent,
  ),
  dividerTheme: const DividerThemeData(
    color: DarkColors.line,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      height: 1.28,
      fontWeight: FontWeight.w700,
      color: DarkColors.ink,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      height: 1.28,
      fontWeight: FontWeight.w700,
      color: DarkColors.ink,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      height: 1.33,
      fontWeight: FontWeight.w700,
      color: DarkColors.ink,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      color: DarkColors.ink,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.43,
      color: DarkColors.stone,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      height: 1.33,
      color: DarkColors.stone,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: DarkColors.surface,
    border: OutlineInputBorder(
      borderRadius: AppRadii.input,
      borderSide: BorderSide(color: DarkColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadii.input,
      borderSide: BorderSide(color: DarkColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadii.input,
      borderSide: BorderSide(color: DarkColors.teal, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: TextStyle(
      fontSize: 14,
      color: DarkColors.stone,
    ),
  ),
);
