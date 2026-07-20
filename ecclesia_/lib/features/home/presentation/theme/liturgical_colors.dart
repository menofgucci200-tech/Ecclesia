import 'package:flutter/material.dart';

/// Maps liturgical colours / seasons to app colours, for the calendar dots
/// and the season-driven theming of the home experience.
class LiturgicalColors {
  const LiturgicalColors._();

  // Dot colours for the calendar (real liturgical colours + parish blue).
  static const Color white = Color(0xFFCFA83C); // blanc / or — solemnities, saints
  static const Color red = Color(0xFFCE3B3B); // martyrs, Pentecôte
  static const Color green = Color(0xFF3E9B6B); // Temps Ordinaire
  static const Color purple = Color(0xFF7A4FB0); // Avent, Carême
  static const Color rose = Color(0xFFDB7FA0); // Gaudete / Laetare
  static const Color parish = Color(0xFF1A6B9E); // événements de la paroisse (bleu)

  /// Dot colour for an agenda item.
  static Color dot({required bool isParish, String? liturgicalColor}) {
    if (isParish) return parish;
    return switch (_normalize(liturgicalColor)) {
      'rouge' => red,
      'vert' => green,
      'violet' => purple,
      'rose' => rose,
      _ => white, // blanc / or (default festive)
    };
  }

  /// Legend entries shown under the calendar.
  static const List<(Color, String)> legend = [
    (white, 'Solennités & saints'),
    (red, 'Martyrs · Pentecôte'),
    (purple, 'Avent · Carême'),
    (green, 'Temps ordinaire'),
    (parish, 'Événements paroisse'),
  ];

  // ---- Season theming (top bar + icons + accents) ---------------------

  /// The theme colour for the *current liturgical season*, derived from the
  /// season name (stable) with a fallback to the day's colour.
  static SeasonTheme season(String? season, String? dayColor) {
    final s = _normalize(season);
    if (s.contains('avent') || s.contains('carem') || s.contains('carême')) {
      return const SeasonTheme(primary: Color(0xFF5B3A94), deep: Color(0xFF472C75), name: 'Violet');
    }
    if (s.contains('noel') || s.contains('noël') || s.contains('pascal') ||
        s.contains('paque') || s.contains('pâque')) {
      return const SeasonTheme(primary: Color(0xFFB8901E), deep: Color(0xFF8F6E12), name: 'Or');
    }
    if (s.contains('ordinaire')) {
      return const SeasonTheme(primary: Color(0xFF1F7A55), deep: Color(0xFF175C40), name: 'Vert');
    }
    // Fallback on the day's liturgical colour.
    return switch (_normalize(dayColor)) {
      'violet' => const SeasonTheme(primary: Color(0xFF5B3A94), deep: Color(0xFF472C75), name: 'Violet'),
      'rouge' => const SeasonTheme(primary: Color(0xFFB23030), deep: Color(0xFF8C2525), name: 'Rouge'),
      'vert' => const SeasonTheme(primary: Color(0xFF1F7A55), deep: Color(0xFF175C40), name: 'Vert'),
      'blanc' => const SeasonTheme(primary: Color(0xFFB8901E), deep: Color(0xFF8F6E12), name: 'Or'),
      _ => const SeasonTheme(primary: Color(0xFF0D3B66), deep: Color(0xFF0A2D50), name: 'Ecclesia'),
    };
  }

  static String _normalize(String? v) => (v ?? '').toLowerCase().trim();
}

/// A season theme: a primary colour and a deeper shade for gradients.
class SeasonTheme {
  const SeasonTheme({required this.primary, required this.deep, required this.name});

  final Color primary;
  final Color deep;
  final String name;
}
