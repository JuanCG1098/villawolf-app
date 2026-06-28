import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale built on **Inter** (loaded via google_fonts, with the platform sans as fallback).
///
/// Styles carry size / line-height / weight / tracking but NOT colour — colour comes from the active
/// theme so the same scale works in dark and light. `overline` is uppercase + wide tracking, used for
/// the wordmark and section eyebrows (per BRAND.md).
class AppTypography {
  AppTypography._();

  static TextStyle _inter({
    required double size,
    required double height,
    required FontWeight weight,
    double tracking = 0,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      letterSpacing: tracking,
    );
  }

  static TextStyle get display =>
      _inter(size: 34, height: 40, weight: FontWeight.w700, tracking: -0.5);
  static TextStyle get h1 =>
      _inter(size: 26, height: 32, weight: FontWeight.w700, tracking: -0.3);
  static TextStyle get h2 =>
      _inter(size: 22, height: 28, weight: FontWeight.w700, tracking: -0.2);
  static TextStyle get h3 =>
      _inter(size: 18, height: 24, weight: FontWeight.w600, tracking: -0.1);
  static TextStyle get title =>
      _inter(size: 16, height: 22, weight: FontWeight.w600, tracking: 0.1);
  static TextStyle get bodyLg =>
      _inter(size: 15, height: 22, weight: FontWeight.w400);
  static TextStyle get body =>
      _inter(size: 14, height: 20, weight: FontWeight.w400);
  static TextStyle get bodySm =>
      _inter(size: 13, height: 18, weight: FontWeight.w400);
  static TextStyle get caption =>
      _inter(size: 12, height: 16, weight: FontWeight.w400);
  static TextStyle get overline => _inter(
        size: 11,
        height: 14,
        weight: FontWeight.w600,
        tracking: 1.5,
      );

  /// Builds a Material [TextTheme] from the scale, tinted with the supplied text colours.
  static TextTheme textTheme({required Color primary, required Color secondary}) {
    TextStyle p(TextStyle s) => s.copyWith(color: primary);
    TextStyle sc(TextStyle s) => s.copyWith(color: secondary);
    return TextTheme(
      displayLarge: p(display),
      headlineLarge: p(h1),
      headlineMedium: p(h2),
      headlineSmall: p(h3),
      titleLarge: p(title),
      titleMedium: p(title),
      bodyLarge: p(bodyLg),
      bodyMedium: p(body),
      bodySmall: sc(bodySm),
      labelLarge: p(body.copyWith(fontWeight: FontWeight.w600)),
      labelSmall: sc(overline),
    );
  }
}
