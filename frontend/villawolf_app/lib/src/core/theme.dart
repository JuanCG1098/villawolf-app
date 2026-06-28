import 'package:flutter/material.dart';

/// Legacy colour facade — kept so the existing feature screens keep compiling while they still
/// reference colours directly. Values mirror the **dark** design tokens
/// (`lib/src/design/tokens/semantic_tokens.dart`).
///
/// DEPRECATED: new code must read colours from the active theme via `context.tokens`
/// (see `lib/src/design/theme/app_tokens_extension.dart`). Screens still using `AppColors` are
/// pinned to the dark preset and will be migrated to tokens in a later pass.
///
/// NOTE: intentionally not annotated `@Deprecated` to avoid ~90 same-package warnings while the
/// screens are mid-migration; treat as deprecated by convention.
class AppColors {
  static const ink = Color(0xFF0A0A0B);
  static const surface = Color(0xFF161619);
  static const surfaceAlt = Color(0xFF1C1C20);
  static const line = Color(0xFF232328);
  static const onInk = Color(0xFFF3F3F2);
  static const muted = Color(0xFF7A7A82);
  static const accent = Color(0xFFC8B68A);

  // Desaturated status colours.
  static const green = Color(0xFF6FBF8B);
  static const amber = Color(0xFFD9B567);
  static const red = Color(0xFFCF7B7B);
  static const blue = Color(0xFF7FA8D9);
}
