import 'package:flutter/material.dart';

/// Monochrome VILLAWOLF palette (see docs/BRAND.md): black & white with a subtle champagne accent.
class AppColors {
  static const ink = Color(0xFF0B0B0C);
  static const surface = Color(0xFF161617);
  static const surfaceAlt = Color(0xFF1F1F22);
  static const line = Color(0xFF2A2A2E);
  static const onInk = Color(0xFFF5F5F4);
  static const muted = Color(0xFF9A9A9E);
  static const accent = Color(0xFFC8B68A);

  // Desaturated status colours.
  static const green = Color(0xFF6FBF8B);
  static const amber = Color(0xFFD9B567);
  static const red = Color(0xFFCF7B7B);
  static const blue = Color(0xFF7FA8D9);
}

class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.accent,
      onPrimary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.onInk,
    );

    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.ink,
      dividerColor: AppColors.line,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.onInk,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        hintStyle: const TextStyle(color: AppColors.muted),
        labelStyle: const TextStyle(color: AppColors.muted),
        border: border(AppColors.line),
        enabledBorder: border(AppColors.line),
        focusedBorder: border(AppColors.accent),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.ink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accent),
      ),
      iconTheme: const IconThemeData(color: AppColors.muted),
    );
  }
}
