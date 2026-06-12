import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class BaanaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: BaanaColors.background,
      primaryColor: BaanaColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BaanaColors.primary,
        primary: BaanaColors.primary,
        secondary: BaanaColors.accent,
        surface: BaanaColors.background,
        error: BaanaColors.error,
      ),
      textTheme: BaanaTypography.getTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: BaanaColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: BaanaColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: BaanaTypography.headlineFont,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: BaanaColors.textPrimary,
        ),
      ),
    );
  }
}
