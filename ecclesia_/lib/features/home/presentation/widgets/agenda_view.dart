import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/home_data.dart';
import '../providers/home_provider.dart';
import '../theme/home_palette.dart';

/// The "Agenda" tab: major liturgical feasts + parish events, grouped by month.
class AgendaView extends ConsumerWidget {
  const AgendaView({super.key});

  static const _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(agendaProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(color: HomePalette.navy)),
      error: (e, _) => _AgendaMessage(
        icon: Icons.wifi_off_rounded,
        text: 'Impossible de charger l\'agenda.',
        onRetry: () => ref.invalidate(agendaProvider),
      ),
      data: (events) {
        if (events.isEmpty) {
          return const _AgendaMessage(icon: Icons.event_busy_outlined, text: 'Aucun événement à venir.');
        }

        // Group by "year-month".
        final groups = <String, List<AgendaEvent>>{};
        for (final e in events) {
          groups.putIfAbsent('${e.date.year}-${e.date.month}', () => []).add(e);
        }

        return RefreshIndicator(
          color: HomePalette.navy,
          onRefresh: () async => ref.invalidate(agendaProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
            children: [
              for (final entry in groups.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 8),
                  child: Text(
                    '${_months[entry.value.first.date.month - 1]} ${entry.value.first.date.year}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: HomePalette.navy, letterSpacing: .3),
                  ),
                ),
                ...entry.value.map((e) => _AgendaTile(event: e)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AgendaTile extends StatelessWidget {
  const _AgendaTile({required this.event});

  final AgendaEvent event;

  static const _weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    final isParish = event.isParish;
    final accent = isParish ? HomePalette.navy : HomePalette.gold;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HomePalette.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomePalette.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Date chip
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(_weekdays[event.date.weekday - 1],
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: accent)),
                Text('${event.date.day}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: accent, height: 1)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(isParish ? Icons.groups_outlined : Icons.church_outlined, size: 13, color: accent),
                    const SizedBox(width: 4),
                    Text(
                      isParish ? 'Événement paroisse' : (event.subtitle ?? 'Fête'),
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: .3, color: accent),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(event.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2A3646), height: 1.25)),
                if (event.time != null || event.location != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    [if (event.time != null) event.time, if (event.location != null) event.location].join(' · '),
                    style: const TextStyle(fontSize: 12, color: HomePalette.textBody),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaMessage extends StatelessWidget {
  const _AgendaMessage({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: HomePalette.textFaint),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: HomePalette.textBody)),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ],
      ),
    );
  }
}
