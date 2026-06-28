import 'package:flutter/material.dart';

import '../tokens/radius.dart';
import '../tokens/semantic_tokens.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Builds Material [ThemeData] from a set of [AppTokens]. Both presets (dark/light) — and any future
/// per-barbershop preset — flow through here, so Material defaults stay consistent with the DS.
class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(AppTokens.dark());
  static ThemeData light() => _build(AppTokens.light());

  static ThemeData _build(AppTokens t) {
    final scheme = ColorScheme.fromSeed(
      seedColor: t.brand,
      brightness: t.brightness,
    ).copyWith(
      primary: t.brand,
      onPrimary: t.onBrand,
      surface: t.bgSurface,
      onSurface: t.textPrimary,
      error: t.dangerFg,
      outline: t.borderDefault,
    );

    OutlineInputBorder border(Color c, [double w = AppSizing.borderThin]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: t.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: t.bgBase,
      canvasColor: t.bgBase,
      dividerColor: t.borderDefault,
      splashFactory: InkSparkle.splashFactory,
      extensions: [t],
      textTheme:
          AppTypography.textTheme(primary: t.textPrimary, secondary: t.textSecondary),
      dividerTheme: DividerThemeData(
        color: t.borderDefault,
        thickness: AppSizing.borderThin,
        space: AppSpacing.lg,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.bgBase,
        foregroundColor: t.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.title.copyWith(color: t.textPrimary),
      ),
      iconTheme: IconThemeData(color: t.textMuted, size: AppSizing.iconMd),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.bgSurfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        hintStyle: AppTypography.body.copyWith(color: t.textMuted),
        labelStyle: AppTypography.bodySm.copyWith(color: t.textMuted),
        floatingLabelStyle: AppTypography.bodySm.copyWith(color: t.brand),
        border: border(t.borderDefault),
        enabledBorder: border(t.borderDefault),
        focusedBorder: border(t.focusRing, AppSizing.borderThick),
        errorBorder: border(t.dangerBorder),
        focusedErrorBorder: border(t.dangerFg, AppSizing.borderThick),
        errorStyle: AppTypography.caption.copyWith(color: t.dangerFg),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.brand,
          foregroundColor: t.onBrand,
          disabledBackgroundColor: t.bgSurfaceAlt,
          disabledForegroundColor: t.textDisabled,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          minimumSize: const Size(0, AppSizing.controlMd),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.textPrimary,
          side: BorderSide(color: t.borderStrong),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          minimumSize: const Size(0, AppSizing.controlMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.brand,
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: t.bgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brLg,
          side: BorderSide(color: t.borderDefault),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.bgElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brLg,
          side: BorderSide(color: t.borderDefault),
        ),
        titleTextStyle: AppTypography.h3.copyWith(color: t.textPrimary),
        contentTextStyle: AppTypography.body.copyWith(color: t.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.bgElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.bgElevated,
        contentTextStyle: AppTypography.body.copyWith(color: t.textPrimary),
        actionTextColor: t.brand,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brMd,
          side: BorderSide(color: t.borderDefault),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.bgElevated,
          borderRadius: AppRadius.brSm,
          border: Border.all(color: t.borderDefault),
        ),
        textStyle: AppTypography.caption.copyWith(color: t.textPrimary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.bgSurfaceAlt,
        side: BorderSide(color: t.borderDefault),
        labelStyle: AppTypography.bodySm.copyWith(color: t.textSecondary),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brFull),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: t.brand),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(t.borderStrong),
      ),
    );
  }
}
