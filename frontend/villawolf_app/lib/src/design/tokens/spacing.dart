import 'package:flutter/widgets.dart';

/// Base-4 spacing scale. Use these instead of magic numbers so density stays consistent and is easy
/// to retune per brand later.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double xl3 = 32;
  static const double xl4 = 40;
  static const double xl5 = 48;
  static const double xl6 = 64;

  /// Common gaps as ready-to-use [SizedBox]es (vertical).
  static const gapXs = SizedBox(height: xs);
  static const gapSm = SizedBox(height: sm);
  static const gapMd = SizedBox(height: md);
  static const gapLg = SizedBox(height: lg);
  static const gapXl = SizedBox(height: xl);
  static const gapXl2 = SizedBox(height: xl2);

  /// Common gaps (horizontal).
  static const wXs = SizedBox(width: xs);
  static const wSm = SizedBox(width: sm);
  static const wMd = SizedBox(width: md);
  static const wLg = SizedBox(width: lg);
}

/// Control heights and icon sizes — keep interactive targets consistent.
class AppSizing {
  AppSizing._();

  static const double controlSm = 32;
  static const double controlMd = 40;
  static const double controlLg = 48;

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;

  static const double borderThin = 1;
  static const double borderThick = 1.5;

  /// Sidebar / nav rail width on wide layouts.
  static const double navWidth = 240;
}
