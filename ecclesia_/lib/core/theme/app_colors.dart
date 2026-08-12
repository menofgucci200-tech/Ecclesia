import 'package:flutter/material.dart';

/// Ecclesia brand palette, derived from the visual identity guide:
/// Bleu Marial · Or Liturgique · Blanc.
///
/// These values are the same as [HomePalette] (`features/home/.../home_palette.dart`)
/// — the Home dashboard was the most visually resolved part of the app, so
/// its palette became the single source of truth for the whole app's
/// [AppTheme] instead of the other way around. `HomePalette` still exists
/// (its call sites are migrated screen by screen) but the two are now
/// numerically identical.
class AppColors {
  const AppColors._();

  // Bleu Marial — primary institutional navy.
  static const Color navy = Color(0xFF0D3B66);
  static const Color navyDark = Color(0xFF0A2D50);
  static const Color navyLight = Color(0xFF1A6B9E);

  // Or Liturgique — used sparingly for premium / sacred accents.
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE3B94A);

  // Blanc & neutrals.
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF4F6F9);
  static const Color border = Color(0xFFEAEFF6);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Text.
  static const Color textPrimary = Color(0xFF1F2A44);
  static const Color textSecondary = Color(0xFF8795A8);
  static const Color textHint = Color(0xFF9AA7B8);
  static const Color textMuted = Color(0xFF9AA7B8);
  static const Color textFaint = Color(0xFFB0BBC9);
  static const Color textOnNavy = Color(0xFFFFFFFF);

  // Feedback.
  static const Color success = Color(0xFF4CAF8A);
  static const Color error = Color(0xFFE05252);
  static const Color warning = Color(0xFFD97706);

  // Helper pill (Besoin d'aide ?).
  static const Color helpBackground = Color(0xFFE8F0FB);
}
