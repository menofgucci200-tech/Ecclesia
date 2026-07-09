import 'package:flutter/material.dart';

/// Colour tokens taken verbatim from the "Ecran8 Accueil" Claude Design
/// hand-off, kept separate from [AppColors] so the home dashboard matches the
/// premium mockup pixel-for-pixel without shifting the rest of the app's palette.
class HomePalette {
  const HomePalette._();

  // Brand.
  static const Color gold = Color(0xFFD4AF37);
  static const Color navy = Color(0xFF0D3B66);
  static const Color navyDeep = Color(0xFF0A2D50);

  // Surfaces.
  static const Color screenBg = Color(0xFFF7F8FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEAEFF6);
  static const Color hairline = Color(0xFFF0F4F8);
  static const Color navPill = Color(0xFFE8F0FB);

  // Text.
  static const Color textBody = Color(0xFF8795A8);
  static const Color textMuted = Color(0xFF9AA7B8);
  static const Color textAuthor = Color(0xFF6B7D92);
  static const Color textFaint = Color(0xFFB0BBC9);

  // Accents.
  static const Color red = Color(0xFFE05252);
  static const Color green = Color(0xFF4CAF8A);
}
