import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0B6B63);
  static const Color ink = Color(0xFF1B2B2A);
  static const Color muted = Color(0xFF5B6867);
  static const Color border = Color(0xFFD5DBDB);
  static const Color correct = Color(0xFF9BE3B5);
  static const Color correctDark = Color(0xFF2E9E5B);
  static const Color incorrect = Color(0xFFFFA3A3);
  static const Color incorrectDark = Color(0xFFD64545);
  static const Color error = Color(0xFFB3261E);
  static const Color errorSurface = Color(0xFFFDECEA);
  static const Color warmBadge = Color(0xFFD93A1F);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      error: AppColors.error,
    );
    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    const buttonText = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFDDE4E3),
          disabledForegroundColor: AppColors.muted,
          minimumSize: const Size.fromHeight(52),
          shape: buttonShape,
          textStyle: buttonText,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        thumbColor: AppColors.primary,
        inactiveTrackColor: Color(0xFFD5DBDB),
        valueIndicatorColor: AppColors.primary,
      ),
    );
  }
}
