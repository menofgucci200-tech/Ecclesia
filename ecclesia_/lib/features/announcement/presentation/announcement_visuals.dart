import 'package:flutter/material.dart';

import '../../home/presentation/theme/home_palette.dart';

/// Maps an announcement category to the feed card's header gradient, badge
/// colour and icon, so the parish feed keeps the mockup's colourful variety
/// even though the API only sends a category slug.
class AnnouncementVisual {
  const AnnouncementVisual({
    required this.gradient,
    required this.badgeColor,
    required this.icon,
    required this.authorColor,
  });

  final List<Color> gradient;
  final Color badgeColor;
  final IconData icon;
  final Color authorColor;

  static AnnouncementVisual forCategory(String category) {
    switch (category) {
      case 'event':
        return const AnnouncementVisual(
          gradient: [Color(0xFF1E4D20), Color(0xFF3A8C3A), Color(0xFF6ABE6A)],
          badgeColor: Color(0xFFA8E6A8),
          icon: Icons.event_outlined,
          authorColor: HomePalette.gold,
        );
      case 'celebration':
        return const AnnouncementVisual(
          gradient: [Color(0xFF3D1A78), Color(0xFF6B3AAA), Color(0xFF9B6BDD)],
          badgeColor: Color(0xFFE7D9FF),
          icon: Icons.celebration_outlined,
          authorColor: HomePalette.navy,
        );
      case 'testimony':
        return const AnnouncementVisual(
          gradient: [Color(0xFF7B4B1A), Color(0xFFB5852F), Color(0xFFD9AE52)],
          badgeColor: Color(0xFFF7E7C4),
          icon: Icons.format_quote,
          authorColor: HomePalette.navy,
        );
      case 'formation':
        return const AnnouncementVisual(
          gradient: [Color(0xFF0D3B66), Color(0xFF1A5F9E), Color(0xFF2A80C8)],
          badgeColor: Color(0xFFCDE7FF),
          icon: Icons.school_outlined,
          authorColor: HomePalette.navy,
        );
      case 'announcement':
      default:
        return const AnnouncementVisual(
          gradient: [Color(0xFF0D3B66), Color(0xFF1A6B9E), Color(0xFF3A9BCF)],
          badgeColor: HomePalette.gold,
          icon: Icons.campaign_outlined,
          authorColor: HomePalette.navy,
        );
    }
  }
}
