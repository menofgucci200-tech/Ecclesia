import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/theme/home_palette.dart';
import '../providers/movements_provider.dart';

/// A movement's page: description, join/leave, posts and documents.
class MovementDetailScreen extends ConsumerWidget {
  const MovementDetailScreen({super.key, required this.id, required this.name});

  final int id;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(movementDetailProvider(id));

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: HomePalette.navy)),
        error: (e, _) => Center(child: TextButton(onPressed: () => ref.invalidate(movementDetailProvider(id)), child: const Text('Réessayer'))),
        data: (detail) {
          final m = detail.movement;
          return RefreshIndicator(
            color: HomePalette.navy,
            onRefresh: () async => ref.invalidate(movementDetailProvider(id)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              children: [
                Row(
                  children: [
                    Container(
                      width: 64, height: 64, clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(color: HomePalette.navy.withValues(alpha: .08), borderRadius: BorderRadius.circular(16)),
                      child: m.logoUrl != null
                          ? Image.network(m.logoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.groups_outlined, color: HomePalette.navy, size: 30))
                          : const Icon(Icons.groups_outlined, color: HomePalette.navy, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                          if (m.category != null) Text(m.category!, style: const TextStyle(fontSize: 13, color: HomePalette.textBody)),
                          Text('${m.membersCount} membre(s)', style: const TextStyle(fontSize: 12, color: HomePalette.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _JoinButton(id: m.id, isMember: m.isMember, ref: ref),
                if ((m.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(m.description!, style: const TextStyle(fontSize: 14, color: Color(0xFF44515F), height: 1.55)),
                ],
                if ((m.meetingInfo ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.schedule, size: 16, color: HomePalette.textBody),
                    const SizedBox(width: 6),
                    Text(m.meetingInfo!, style: const TextStyle(fontSize: 13, color: HomePalette.textBody)),
                  ]),
                ],

                if (detail.documents.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const _SectionTitle('Documents'),
                  ...detail.documents.map((d) => Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: HomePalette.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: HomePalette.cardBorder)),
                        child: Row(children: [
                          const Icon(Icons.description_outlined, color: HomePalette.navy),
                          const SizedBox(width: 10),
                          Expanded(child: Text(d.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
                          if (d.size != null) Text(d.size!, style: const TextStyle(fontSize: 11, color: HomePalette.textMuted)),
                        ]),
                      )),
                ],

                const SizedBox(height: 22),
                const _SectionTitle('Annonces'),
                if (detail.posts.isEmpty)
                  const Padding(padding: EdgeInsets.only(top: 8), child: Text('Aucune annonce pour le moment.', style: TextStyle(color: HomePalette.textBody)))
                else
                  ...detail.posts.map((p) => Container(
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(color: HomePalette.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: HomePalette.cardBorder)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (p.imageUrl != null) Image.network(p.imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                                  const SizedBox(height: 6),
                                  Text(p.body, style: const TextStyle(fontSize: 13.5, color: Color(0xFF44515F), height: 1.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _JoinButton extends StatefulWidget {
  const _JoinButton({required this.id, required this.isMember, required this.ref});
  final int id;
  final bool isMember;
  final WidgetRef ref;

  @override
  State<_JoinButton> createState() => _JoinButtonState();
}

class _JoinButtonState extends State<_JoinButton> {
  late bool _isMember = widget.isMember;
  bool _busy = false;

  Future<void> _toggle() async {
    setState(() => _busy = true);
    try {
      final ds = widget.ref.read(movementDataSourceProvider);
      _isMember ? await ds.leave(widget.id) : await ds.join(widget.id);
      if (mounted) setState(() => _isMember = !_isMember);
      widget.ref.invalidate(myMovementsProvider);
      widget.ref.invalidate(parishMovementsProvider);
      widget.ref.invalidate(movementDetailProvider(widget.id));
    } catch (_) {} finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _isMember
          ? OutlinedButton.icon(
              onPressed: _busy ? null : _toggle,
              style: OutlinedButton.styleFrom(foregroundColor: HomePalette.navy, side: const BorderSide(color: HomePalette.cardBorder), padding: const EdgeInsets.symmetric(vertical: 12)),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Vous êtes membre — Quitter'),
            )
          : FilledButton.icon(
              onPressed: _busy ? null : _toggle,
              style: FilledButton.styleFrom(backgroundColor: HomePalette.gold, foregroundColor: HomePalette.navy, padding: const EdgeInsets.symmetric(vertical: 12)),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Rejoindre ce mouvement'),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: HomePalette.navy));
}
