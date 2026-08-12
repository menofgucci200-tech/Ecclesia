import 'package:flutter/material.dart';

import '../../home/presentation/theme/home_palette.dart';
import '../data/prayer.dart';

/// A calm reading view for a single prayer / rosary / novena, preserving the
/// original line breaks of the text.
class PrayerDetailScreen extends StatelessWidget {
  const PrayerDetailScreen({super.key, required this.prayer});

  final Prayer prayer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          prayer.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          if ((prayer.imageUrl ?? '').isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                prayer.imageUrl!,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 18),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: HomePalette.gold.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              prayer.categoryLabel.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF8A6D1B), letterSpacing: .5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            prayer.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: HomePalette.navy, height: 1.2),
          ),
          if ((prayer.subtitle ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(prayer.subtitle!, style: const TextStyle(fontSize: 14, color: HomePalette.textBody)),
          ],
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: HomePalette.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: HomePalette.cardBorder),
            ),
            child: SelectableText(
              prayer.body,
              style: const TextStyle(fontSize: 16, height: 1.75, color: HomePalette.textBody),
            ),
          ),
          if ((prayer.reference ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.menu_book_outlined, size: 15, color: HomePalette.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(prayer.reference!, style: const TextStyle(fontSize: 12.5, color: HomePalette.textMuted, fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
