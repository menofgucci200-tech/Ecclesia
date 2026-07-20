import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/theme/home_palette.dart';
import '../../data/models/movement.dart';
import '../providers/movements_provider.dart';
import 'movement_detail_screen.dart';

/// Lists the parish movements; the faithful joins the ones they belong to.
class MovementsScreen extends ConsumerWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(parishMovementsProvider);

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mouvements', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: HomePalette.navy)),
        error: (e, _) => _Message(
          text: 'Impossible de charger les mouvements.',
          onRetry: () => ref.invalidate(parishMovementsProvider),
        ),
        data: (movements) {
          if (movements.isEmpty) {
            return const _Message(text: 'Aucun mouvement dans votre paroisse pour l\'instant.');
          }
          return RefreshIndicator(
            color: HomePalette.navy,
            onRefresh: () async => ref.invalidate(parishMovementsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: movements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _MovementCard(movement: movements[i]),
            ),
          );
        },
      ),
    );
  }
}

class _MovementCard extends ConsumerStatefulWidget {
  const _MovementCard({required this.movement});

  final Movement movement;

  @override
  ConsumerState<_MovementCard> createState() => _MovementCardState();
}

class _MovementCardState extends ConsumerState<_MovementCard> {
  late bool _isMember = widget.movement.isMember;
  bool _busy = false;

  Future<void> _toggle() async {
    setState(() => _busy = true);
    try {
      final ds = ref.read(movementDataSourceProvider);
      if (_isMember) {
        await ds.leave(widget.movement.id);
      } else {
        await ds.join(widget.movement.id);
      }
      if (mounted) setState(() => _isMember = !_isMember);
      ref.invalidate(myMovementsProvider);
      ref.invalidate(parishMovementsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action impossible. Réessayez.'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.movement;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MovementDetailScreen(id: m.id, name: m.name)),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HomePalette.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HomePalette.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: HomePalette.navy.withValues(alpha: .08), borderRadius: BorderRadius.circular(14)),
              child: m.logoUrl != null
                  ? Image.network(m.logoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.groups_outlined, color: HomePalette.navy))
                  : const Icon(Icons.groups_outlined, color: HomePalette.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                  if (m.category != null)
                    Text(m.category!, style: const TextStyle(fontSize: 12, color: HomePalette.textBody)),
                  Text('${m.membersCount} membre(s)', style: const TextStyle(fontSize: 11.5, color: HomePalette.textMuted)),
                ],
              ),
            ),
            SizedBox(
              height: 34,
              child: _busy
                  ? const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                  : _isMember
                      ? OutlinedButton(
                          onPressed: _toggle,
                          style: OutlinedButton.styleFrom(foregroundColor: HomePalette.navy, side: const BorderSide(color: HomePalette.cardBorder), padding: const EdgeInsets.symmetric(horizontal: 12)),
                          child: const Text('Membre ✓', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        )
                      : FilledButton(
                          onPressed: _toggle,
                          style: FilledButton.styleFrom(backgroundColor: HomePalette.gold, foregroundColor: HomePalette.navy, padding: const EdgeInsets.symmetric(horizontal: 14)),
                          child: const Text('Rejoindre', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.groups_outlined, size: 44, color: HomePalette.textFaint),
          const SizedBox(height: 12),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: HomePalette.textBody))),
          if (onRetry != null) ...[const SizedBox(height: 12), TextButton(onPressed: onRetry, child: const Text('Réessayer'))],
        ],
      ),
    );
  }
}
