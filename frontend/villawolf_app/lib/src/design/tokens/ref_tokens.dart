import 'package:flutter/widgets.dart';

/// Reference (primitive) tokens — the raw palette. These have no semantic meaning on their own;
/// [AppTokens] maps them to roles (background, text, border, ...) per theme mode.
///
/// Villa Wolf is a monochrome black & white identity (see docs/BRAND.md) with an optional champagne
/// accent. The neutral ramp is a slightly cool near-black → white scale; the look & feel is inspired
/// by dev/admin dashboards (Linear, Vercel/Geist, Stripe, Notion) — hairline borders, restrained
/// radii and desaturated status colours.
class RefColors {
  RefColors._();

  // ── Neutral ramp (cool, n0 = near-black → n1000 = white) ──────────────────────────────────────
  static const n0 = Color(0xFF0A0A0B);
  static const n50 = Color(0xFF111113);
  static const n100 = Color(0xFF161619);
  static const n150 = Color(0xFF1C1C20);
  static const n200 = Color(0xFF232328);
  static const n250 = Color(0xFF2A2A2F);
  static const n300 = Color(0xFF34343A);
  static const n400 = Color(0xFF45454C);
  static const n500 = Color(0xFF5E5E66);
  static const n600 = Color(0xFF7A7A82);
  static const n700 = Color(0xFF9A9AA0);
  static const n800 = Color(0xFFBFBFC4);
  static const n850 = Color(0xFFD4D4D7);
  static const n900 = Color(0xFFE7E7E9);
  static const n950 = Color(0xFFF3F3F2);
  static const n1000 = Color(0xFFFFFFFF);

  // ── Champagne accent ──────────────────────────────────────────────────────────────────────────
  static const champagne = Color(0xFFC8B68A);
  static const champagneBright = Color(0xFFD8C7A0);
  static const champagneDeep = Color(0xFF9C8959); // legible on light surfaces

  // ── Status (desaturated, per BRAND.md) ───────────────────────────────────────────────────────
  static const green = Color(0xFF6FBF8B);
  static const greenDeep = Color(0xFF3E8F5E);
  static const amber = Color(0xFFD9B567);
  static const amberDeep = Color(0xFFA9803A);
  static const red = Color(0xFFCF7B7B);
  static const redDeep = Color(0xFFB04A4A);
  static const blue = Color(0xFF7FA8D9);
  static const blueDeep = Color(0xFF4A77AB);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}
