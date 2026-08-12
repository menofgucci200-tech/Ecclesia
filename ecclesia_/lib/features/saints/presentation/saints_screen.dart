import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/message_card.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/saint.dart';
import '../data/saint_providers.dart';

/// "Saint du jour" — today's saint with image and biography, and a date
/// navigator to browse other days.
class SaintsScreen extends ConsumerStatefulWidget {
  const SaintsScreen({super.key});

  @override
  ConsumerState<SaintsScreen> createState() => _SaintsScreenState();
}

class _SaintsScreenState extends ConsumerState<SaintsScreen> {
  DateTime _date = DateTime.now();

  static const _days = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
  static const _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];

  String get _dateKey =>
      '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  String get _dateLabel => '${_days[_date.weekday - 1]} ${_date.day} ${_months[_date.month - 1]}';

  bool get _isToday {
    final now = DateTime.now();
    return _date.year == now.year && _date.month == now.month && _date.day == now.day;
  }

  void _shift(int days) => setState(() => _date = _date.add(Duration(days: days)));

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
    final async = ref.watch(saintProvider(_dateKey));

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Saint du jour', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: Column(
        children: [
          _DateBar(
            label: _isToday ? "Aujourd'hui" : _dateLabel,
            sub: _isToday ? _dateLabel : null,
            onPrev: () => _shift(-1),
            onNext: () => _shift(1),
            onPick: _pick,
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator(color: HomePalette.navy)),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: MessageCard.fromException(
                    e is ApiException ? e : const UnknownException('Une erreur est survenue.'),
                    onRetry: () => ref.invalidate(saintProvider(_dateKey)),
                  ),
                ),
              ),
              data: (saint) => (saint != null && saint.hasSaint)
                  ? _SaintBody(saint: saint)
                  : _NoSaint(liturgicalDay: saint?.liturgicalDay),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBar extends StatelessWidget {
  const _DateBar({required this.label, required this.onPrev, required this.onNext, required this.onPick, this.sub});

  final String label;
  final String? sub;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HomePalette.navy,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left, color: Colors.white)),
          Expanded(
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  if (sub != null) Text(sub!, style: TextStyle(color: Colors.white.withValues(alpha: .7), fontSize: 12)),
                ],
              ),
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right, color: Colors.white)),
        ],
      ),
    );
  }
}

class _SaintBody extends StatelessWidget {
  const _SaintBody({required this.saint});
  final Saint saint;

  Future<void> _openWiki() async {
    if (saint.wikipediaUrl != null) {
      await launchUrl(Uri.parse(saint.wikipediaUrl!), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
      children: [
        if ((saint.imageUrl ?? '').isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              saint.imageUrl!,
              width: double.infinity,
              height: 230,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        const SizedBox(height: 16),
        Text(saint.name ?? saint.feast ?? 'Saint du jour',
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: HomePalette.navy, height: 1.2)),
        if ((saint.feast ?? '').isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(saint.feast!, style: const TextStyle(fontSize: 14, color: HomePalette.textBody)),
        ],
        const SizedBox(height: 16),
        if ((saint.summary ?? '').isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: HomePalette.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: HomePalette.cardBorder),
            ),
            child: Text(saint.summary!, style: const TextStyle(fontSize: 15.5, height: 1.7, color: HomePalette.textBody)),
          )
        else
          const Text('Biographie bientôt disponible.', style: TextStyle(color: HomePalette.textMuted, fontStyle: FontStyle.italic)),
        if ((saint.wikipediaUrl ?? '').isNotEmpty) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _openWiki,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Lire sur Wikipédia'),
              style: OutlinedButton.styleFrom(foregroundColor: HomePalette.navy, side: const BorderSide(color: HomePalette.cardBorder)),
            ),
          ),
        ],
      ],
    );
  }
}

class _NoSaint extends StatelessWidget {
  const _NoSaint({this.liturgicalDay});
  final String? liturgicalDay;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_outlined, size: 48, color: HomePalette.textMuted),
            const SizedBox(height: 14),
            const Text('Pas de saint majeur ce jour', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: HomePalette.navy)),
            if ((liturgicalDay ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(liturgicalDay!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: HomePalette.textBody)),
            ],
          ],
        ),
      ),
    );
  }
}
