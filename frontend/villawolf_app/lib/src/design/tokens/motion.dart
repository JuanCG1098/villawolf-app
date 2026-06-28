import 'package:flutter/animation.dart';

/// Motion tokens — keep transitions quick and calm (premium, not flashy).
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);

  /// Standard easing for most UI state changes.
  static const Curve standard = Curves.easeInOutCubic;

  /// Emphasized easing for entrances / larger movements.
  static const Curve emphasized = Curves.easeOutCubic;
}
