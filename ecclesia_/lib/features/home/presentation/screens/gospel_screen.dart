import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/home_data.dart';
import '../providers/home_provider.dart';
import '../theme/home_palette.dart';
import 'liturgy_screen.dart';

/// "Évangile du jour" — the day's Gospel highlighted, with the acclamation, an
/// optional meditation, date navigation and a link to all the readings.
class GospelScreen extends ConsumerStatefulWidget {
  const GospelScreen({super.key});

  @override
  ConsumerState<GospelScreen> createState() => _GospelScreenState();
}

class _GospelScreenState extends ConsumerState<GospelScreen> {
  DateTime _date = DateTime.now();

  static const _days = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
  static const _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];

  String get _key =>
      '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  String get _label => '${_days[_date.weekday - 1]} ${_date.day} ${_months[_date.month - 1]}';

  bool get _isToday {
    final n = DateTime.now();
    return _date.year == n.year && _date.month == n.month && _date.day == n.day;
  }

  void _shift(int d) => setState(() => _date = _date.add(Duration(days: d)));

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(liturgyForDateProvider(_key));

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Évangile du jour', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: Column(
        children: [
          Container(
            color: HomePalette.navy,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Row(
              children: [
                IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left, color: Colors.white)),
                Expanded(
                  child: InkWell(
                    onTap: _pick,
                    child: Column(
                      children: [
                        Text(_isToday ? "Aujourd'hui" : _label,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                        if (_isToday) Text(_label, style: TextStyle(color: Colors.white.withValues(alpha: .7), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator(color: HomePalette.navy)),
              error: (e, _) => Center(
                child: TextButton(onPressed: () => ref.invalidate(liturgyForDateProvider(_key)), child: const Text('Réessayer')),
              ),
              data: (liturgy) => (liturgy == null)
                  ? const Center(child: Text('Évangile indisponible pour ce jour.', style: TextStyle(color: HomePalette.textBody)))
                  : _GospelBody(liturgy: liturgy),
            ),
          ),
        ],
      ),
    );
  }
}

class _GospelBody extends StatelessWidget {
  const _GospelBody({required this.liturgy});
  final LiturgyModel liturgy;

  @override
  Widget build(BuildContext context) {
    final gospel = liturgy.gospel;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
      children: [
        Text(liturgy.liturgicalDay,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: HomePalette.navy, height: 1.25)),
        if ((liturgy.color ?? '').isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Couleur liturgique : ${liturgy.color}', style: const TextStyle(fontSize: 12.5, color: HomePalette.textMuted)),
        ],
        const SizedBox(height: 18),

        if (gospel == null)
          const Text("L'Évangile n'est pas disponible pour ce jour.", style: TextStyle(color: HomePalette.textBody))
        else ...[
          // Acclamation before the Gospel.
          if ((gospel.verse ?? '').isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: HomePalette.gold.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: HomePalette.gold.withValues(alpha: .3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ACCLAMATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .6, color: Color(0xFF8A6D1B))),
                  const SizedBox(height: 6),
                  Text(_htmlToText(gospel.verse!), style: const TextStyle(fontSize: 14, height: 1.55, color: HomePalette.textBody, fontStyle: FontStyle.italic)),
                ],
              ),
            ),

          // The Gospel itself, prominent.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
                      decoration: BoxDecoration(color: HomePalette.navy, borderRadius: BorderRadius.circular(8)),
                      child: const Text('ÉVANGILE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .6, color: Colors.white)),
                    ),
                    const Spacer(),
                    if ((gospel.ref ?? '').isNotEmpty)
                      Flexible(child: Text(gospel.ref!, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: HomePalette.gold))),
                  ],
                ),
                if ((gospel.title ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(gospel.title!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: HomePalette.navy, height: 1.35)),
                ],
                const SizedBox(height: 12),
                SelectableText(_htmlToText(gospel.content ?? ''),
                    style: const TextStyle(fontSize: 16, height: 1.75, color: Color(0xFF3A4657))),
              ],
            ),
          ),
        ],

        // Meditation (enrichment).
        if ((liturgy.meditation ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF16335B), Color(0xFF2B4E7E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: HomePalette.gold, size: 18),
                    SizedBox(width: 8),
                    Text('Méditation du jour', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(liturgy.meditation!.trim(), style: TextStyle(fontSize: 15, height: 1.7, color: Colors.white.withValues(alpha: .92))),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LiturgyScreen(liturgy: liturgy))),
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: const Text('Toutes les lectures du jour'),
            style: OutlinedButton.styleFrom(
              foregroundColor: HomePalette.navy,
              side: const BorderSide(color: HomePalette.cardBorder),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ],
    );
  }

  /// Small HTML → readable text conversion (AELF content is light HTML).
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
        .replaceAll('&#8217;', '’');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    return text;
  }
}
