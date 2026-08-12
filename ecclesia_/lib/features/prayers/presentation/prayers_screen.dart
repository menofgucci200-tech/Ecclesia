import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/message_card.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/prayer.dart';
import '../data/prayer_providers.dart';
import 'prayer_detail_screen.dart';

/// Lists the spiritual content for a set of [categories] (e.g. « Prières » or
/// « Chapelets »), grouped by category, each row opening a reading view.
class PrayersScreen extends ConsumerWidget {
  const PrayersScreen({super.key, required this.title, required this.categories});

  final String title;
  final List<String> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prayersProvider);

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: HomePalette.navy)),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: MessageCard.fromException(
              e is ApiException ? e : const UnknownException('Une erreur est survenue.'),
              onRetry: () => ref.invalidate(prayersProvider),
            ),
          ),
        ),
        data: (all) {
          final items = all.where((p) => categories.contains(p.category)).toList();
          if (items.isEmpty) {
            return const _Empty();
          }

          // Group by category label, preserving fetch order (already ordered).
          final groups = <String, List<Prayer>>{};
          for (final p in items) {
            groups.putIfAbsent(p.categoryLabel, () => []).add(p);
          }
          final multiGroup = groups.length > 1;

          return RefreshIndicator(
            color: HomePalette.navy,
            onRefresh: () async => ref.invalidate(prayersProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              children: [
                for (final entry in groups.entries) ...[
                  if (multiGroup)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: HomePalette.textMuted, letterSpacing: 1),
                      ),
                    ),
                  for (final p in entry.value) ...[
                    _PrayerTile(prayer: p),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 6),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({required this.prayer});

  final Prayer prayer;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomePalette.cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PrayerDetailScreen(prayer: prayer)),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomePalette.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: HomePalette.navy.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
                child: (prayer.imageUrl ?? '').isNotEmpty
                    ? Image.network(prayer.imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.auto_stories_outlined, size: 20, color: HomePalette.navy))
                    : const Icon(Icons.auto_stories_outlined, size: 20, color: HomePalette.navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prayer.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: HomePalette.navy)),
                    if ((prayer.subtitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(prayer.subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, color: HomePalette.textBody)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: HomePalette.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 48, color: HomePalette.textMuted),
            SizedBox(height: 12),
            Text(
              'Aucun contenu pour l\'instant.\nRevenez bientôt 🙏',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: HomePalette.textBody, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
