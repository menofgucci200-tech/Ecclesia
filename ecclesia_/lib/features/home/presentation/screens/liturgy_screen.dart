import 'package:flutter/material.dart';

import '../../data/models/home_data.dart';
import '../theme/home_palette.dart';

/// Full readings of the day (AELF), reached from the liturgy card.
class LiturgyScreen extends StatelessWidget {
  const LiturgyScreen({super.key, required this.liturgy});

  final LiturgyModel liturgy;

  static const _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  @override
  Widget build(BuildContext context) {
    final d = liturgy.date;
    final dateLabel = '${d.day} ${_months[d.month - 1]} ${d.year}';

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Liturgie du jour', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
        children: [
          Text(
            liturgy.liturgicalDay,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: HomePalette.navy, height: 1.25),
          ),
          const SizedBox(height: 6),
          Text(
            '$dateLabel${liturgy.color != null ? ' · ${liturgy.color}' : ''}',
            style: const TextStyle(fontSize: 13, color: HomePalette.textBody, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          if (liturgy.readings.isEmpty)
            const Text('Lectures indisponibles pour ce jour.', style: TextStyle(color: HomePalette.textBody))
          else
            ...liturgy.readings.map(_ReadingBlock.new),
        ],
      ),
    );
  }
}

class _ReadingBlock extends StatelessWidget {
  const _ReadingBlock(this.reading);

  final ReadingModel reading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomePalette.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomePalette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: HomePalette.navPill,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reading.label.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .6, color: HomePalette.navy),
                ),
              ),
              const Spacer(),
              if ((reading.ref ?? '').isNotEmpty)
                Flexible(
                  child: Text(
                    reading.ref!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: HomePalette.gold),
                  ),
                ),
            ],
          ),
          if ((reading.title ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              reading.title!,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: HomePalette.navy, height: 1.3),
            ),
          ],
          if ((reading.intro ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(reading.intro!, style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: HomePalette.textBody)),
          ],
          if ((reading.refrain ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('R/ ${_htmlToText(reading.refrain!)}',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: HomePalette.navy, height: 1.5)),
          ],
          const SizedBox(height: 10),
          Text(
            _htmlToText(reading.content ?? ''),
            style: const TextStyle(fontSize: 14, color: Color(0xFF3A4657), height: 1.6),
          ),
        ],
      ),
    );
  }

  /// Very small HTML → readable text conversion (AELF content is light HTML).
  static String _htmlToText(String html) {
    var text = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&laquo;', '«')
        .replaceAll('&raquo;', '»')
        .replaceAll('&rsquo;', '’')
        .replaceAll('&amp;', '&')
        .replaceAll('&#8217;', '’')
        .replaceAll(' ', ' ');
    // Collapse excess blank lines.
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    return text;
  }
}
