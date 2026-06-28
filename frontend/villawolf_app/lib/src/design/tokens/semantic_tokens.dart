import 'package:flutter/material.dart';

import 'ref_tokens.dart';

/// Semantic design tokens — the single source of truth for colour roles and elevation, exposed to
/// the whole app as a [ThemeExtension] so widgets read `Theme.of(context).extension<AppTokens>()`
/// (see `context.tokens`) instead of hardcoded constants.
///
/// Two presets ship today ([AppTokens.dark] / [AppTokens.light]); a per-barbershop preset is just
/// another instance of this class, which is what makes future white-label theming a config change
/// rather than a rewrite.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.brightness,
    required this.bgBase,
    required this.bgSurface,
    required this.bgSurfaceAlt,
    required this.bgElevated,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.textInverse,
    required this.brand,
    required this.brandHover,
    required this.brandSubtle,
    required this.onBrand,
    required this.successFg,
    required this.successBg,
    required this.successBorder,
    required this.warningFg,
    required this.warningBg,
    required this.warningBorder,
    required this.dangerFg,
    required this.dangerBg,
    required this.dangerBorder,
    required this.infoFg,
    required this.infoBg,
    required this.infoBorder,
    required this.hoverOverlay,
    required this.pressedOverlay,
    required this.focusRing,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowLg,
  });

  final Brightness brightness;

  // Surfaces (low → high).
  final Color bgBase;
  final Color bgSurface;
  final Color bgSurfaceAlt;
  final Color bgElevated;

  // Borders / dividers.
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;

  // Text.
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color textInverse;

  // Brand accent.
  final Color brand;
  final Color brandHover;
  final Color brandSubtle;
  final Color onBrand;

  // Status (foreground / tinted background / border).
  final Color successFg;
  final Color successBg;
  final Color successBorder;
  final Color warningFg;
  final Color warningBg;
  final Color warningBorder;
  final Color dangerFg;
  final Color dangerBg;
  final Color dangerBorder;
  final Color infoFg;
  final Color infoBg;
  final Color infoBorder;

  // Interaction overlays.
  final Color hoverOverlay;
  final Color pressedOverlay;
  final Color focusRing;

  // Elevation shadows (per mode).
  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowMd;
  final List<BoxShadow> shadowLg;

  bool get isDark => brightness == Brightness.dark;

  // ── Dark preset (Villa Wolf default) ───────────────────────────────────────────────────────────
  factory AppTokens.dark() => const AppTokens(
        brightness: Brightness.dark,
        bgBase: RefColors.n0,
        bgSurface: RefColors.n100,
        bgSurfaceAlt: RefColors.n150,
        bgElevated: RefColors.n200,
        borderSubtle: RefColors.n150,
        borderDefault: RefColors.n250,
        borderStrong: RefColors.n300,
        textPrimary: RefColors.n950,
        textSecondary: RefColors.n800,
        textMuted: RefColors.n600,
        textDisabled: RefColors.n400,
        textInverse: RefColors.n0,
        brand: RefColors.champagne,
        brandHover: RefColors.champagneBright,
        brandSubtle: Color(0x1FC8B68A),
        onBrand: RefColors.n0,
        successFg: RefColors.green,
        successBg: Color(0x1F6FBF8B),
        successBorder: Color(0x556FBF8B),
        warningFg: RefColors.amber,
        warningBg: Color(0x1FD9B567),
        warningBorder: Color(0x55D9B567),
        dangerFg: RefColors.red,
        dangerBg: Color(0x1FCF7B7B),
        dangerBorder: Color(0x55CF7B7B),
        infoFg: RefColors.blue,
        infoBg: Color(0x1F7FA8D9),
        infoBorder: Color(0x557FA8D9),
        hoverOverlay: Color(0x0DFFFFFF),
        pressedOverlay: Color(0x14FFFFFF),
        focusRing: RefColors.champagne,
        shadowSm: [
          BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
        shadowMd: [
          BoxShadow(color: Color(0x59000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
        shadowLg: [
          BoxShadow(color: Color(0x73000000), blurRadius: 36, offset: Offset(0, 18)),
        ],
      );

  // ── Light preset (clean inverse for web) ───────────────────────────────────────────────────────
  factory AppTokens.light() => const AppTokens(
        brightness: Brightness.light,
        bgBase: Color(0xFFFAFAFA),
        bgSurface: RefColors.n1000,
        bgSurfaceAlt: Color(0xFFF4F4F5),
        bgElevated: RefColors.n1000,
        borderSubtle: Color(0xFFEDEDEF),
        borderDefault: Color(0xFFE2E2E5),
        borderStrong: Color(0xFFCFCFD3),
        textPrimary: Color(0xFF18181B),
        textSecondary: Color(0xFF44444A),
        textMuted: Color(0xFF7A7A82),
        textDisabled: Color(0xFFB0B0B6),
        textInverse: RefColors.n1000,
        brand: RefColors.champagneDeep,
        brandHover: Color(0xFF877446),
        brandSubtle: Color(0x1FC8B68A),
        onBrand: RefColors.n1000,
        successFg: RefColors.greenDeep,
        successBg: Color(0x1A6FBF8B),
        successBorder: Color(0x4D3E8F5E),
        warningFg: RefColors.amberDeep,
        warningBg: Color(0x1AD9B567),
        warningBorder: Color(0x4DA9803A),
        dangerFg: RefColors.redDeep,
        dangerBg: Color(0x1ACF7B7B),
        dangerBorder: Color(0x4DB04A4A),
        infoFg: RefColors.blueDeep,
        infoBg: Color(0x1A7FA8D9),
        infoBorder: Color(0x4D4A77AB),
        hoverOverlay: Color(0x0A000000),
        pressedOverlay: Color(0x14000000),
        focusRing: RefColors.champagneDeep,
        shadowSm: [
          BoxShadow(color: Color(0x14101828), blurRadius: 6, offset: Offset(0, 1)),
        ],
        shadowMd: [
          BoxShadow(color: Color(0x1A101828), blurRadius: 16, offset: Offset(0, 6)),
        ],
        shadowLg: [
          BoxShadow(color: Color(0x24101828), blurRadius: 32, offset: Offset(0, 14)),
        ],
      );

  @override
  AppTokens copyWith({
    Brightness? brightness,
    Color? bgBase,
    Color? bgSurface,
    Color? bgSurfaceAlt,
    Color? bgElevated,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? textInverse,
    Color? brand,
    Color? brandHover,
    Color? brandSubtle,
    Color? onBrand,
    Color? successFg,
    Color? successBg,
    Color? successBorder,
    Color? warningFg,
    Color? warningBg,
    Color? warningBorder,
    Color? dangerFg,
    Color? dangerBg,
    Color? dangerBorder,
    Color? infoFg,
    Color? infoBg,
    Color? infoBorder,
    Color? hoverOverlay,
    Color? pressedOverlay,
    Color? focusRing,
    List<BoxShadow>? shadowSm,
    List<BoxShadow>? shadowMd,
    List<BoxShadow>? shadowLg,
  }) {
    return AppTokens(
      brightness: brightness ?? this.brightness,
      bgBase: bgBase ?? this.bgBase,
      bgSurface: bgSurface ?? this.bgSurface,
      bgSurfaceAlt: bgSurfaceAlt ?? this.bgSurfaceAlt,
      bgElevated: bgElevated ?? this.bgElevated,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      textInverse: textInverse ?? this.textInverse,
      brand: brand ?? this.brand,
      brandHover: brandHover ?? this.brandHover,
      brandSubtle: brandSubtle ?? this.brandSubtle,
      onBrand: onBrand ?? this.onBrand,
      successFg: successFg ?? this.successFg,
      successBg: successBg ?? this.successBg,
      successBorder: successBorder ?? this.successBorder,
      warningFg: warningFg ?? this.warningFg,
      warningBg: warningBg ?? this.warningBg,
      warningBorder: warningBorder ?? this.warningBorder,
      dangerFg: dangerFg ?? this.dangerFg,
      dangerBg: dangerBg ?? this.dangerBg,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      infoFg: infoFg ?? this.infoFg,
      infoBg: infoBg ?? this.infoBg,
      infoBorder: infoBorder ?? this.infoBorder,
      hoverOverlay: hoverOverlay ?? this.hoverOverlay,
      pressedOverlay: pressedOverlay ?? this.pressedOverlay,
      focusRing: focusRing ?? this.focusRing,
      shadowSm: shadowSm ?? this.shadowSm,
      shadowMd: shadowMd ?? this.shadowMd,
      shadowLg: shadowLg ?? this.shadowLg,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    List<BoxShadow> s(List<BoxShadow> a, List<BoxShadow> b) =>
        BoxShadow.lerpList(a, b, t) ?? b;
    return AppTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      bgBase: c(bgBase, other.bgBase),
      bgSurface: c(bgSurface, other.bgSurface),
      bgSurfaceAlt: c(bgSurfaceAlt, other.bgSurfaceAlt),
      bgElevated: c(bgElevated, other.bgElevated),
      borderSubtle: c(borderSubtle, other.borderSubtle),
      borderDefault: c(borderDefault, other.borderDefault),
      borderStrong: c(borderStrong, other.borderStrong),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textMuted: c(textMuted, other.textMuted),
      textDisabled: c(textDisabled, other.textDisabled),
      textInverse: c(textInverse, other.textInverse),
      brand: c(brand, other.brand),
      brandHover: c(brandHover, other.brandHover),
      brandSubtle: c(brandSubtle, other.brandSubtle),
      onBrand: c(onBrand, other.onBrand),
      successFg: c(successFg, other.successFg),
      successBg: c(successBg, other.successBg),
      successBorder: c(successBorder, other.successBorder),
      warningFg: c(warningFg, other.warningFg),
      warningBg: c(warningBg, other.warningBg),
      warningBorder: c(warningBorder, other.warningBorder),
      dangerFg: c(dangerFg, other.dangerFg),
      dangerBg: c(dangerBg, other.dangerBg),
      dangerBorder: c(dangerBorder, other.dangerBorder),
      infoFg: c(infoFg, other.infoFg),
      infoBg: c(infoBg, other.infoBg),
      infoBorder: c(infoBorder, other.infoBorder),
      hoverOverlay: c(hoverOverlay, other.hoverOverlay),
      pressedOverlay: c(pressedOverlay, other.pressedOverlay),
      focusRing: c(focusRing, other.focusRing),
      shadowSm: s(shadowSm, other.shadowSm),
      shadowMd: s(shadowMd, other.shadowMd),
      shadowLg: s(shadowLg, other.shadowLg),
    );
  }
}
