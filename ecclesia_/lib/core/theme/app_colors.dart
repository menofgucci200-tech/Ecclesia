import 'package:flutter/material.dart';

/// Ecclesia brand palette, derived from the visual identity guide:
/// Bleu Marial · Or Liturgique · Blanc.
class AppColors {
  const AppColors._();

  // Bleu Marial — primary institutional navy.
  static const Color navy = Color(0xFF16335B);
  static const Color navyDark = Color(0xFF0F2647);
  static const Color navyLight = Color(0xFF2B4E7E);

  // Or Liturgique — used sparingly for premium / sacred accents.
  static const Color gold = Color(0xFFC6A02C);
  static const Color goldLight = Color(0xFFE3B94A);

  // Blanc & neutrals.
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF4F6F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Text.
  static const Color textPrimary = Color(0xFF1F2A44);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnNavy = Color(0xFFFFFFFF);

  // Feedback.
  static const Color success = Color(0xFF1FA463);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);

  // Helper pill (Besoin d'aide ?).
  static const Color helpBackground = Color(0xFFEAF0F9);
}
