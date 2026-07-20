import 'package:flutter/material.dart';

import '../../../home/presentation/screens/liturgy_today_screen.dart';
import '../../../home/presentation/theme/home_palette.dart';
import '../../../movements/presentation/screens/movements_screen.dart';

/// The "Vie & Foi" hub: a grid of illustrated cards, each opening a universe.
class LifeFaithScreen extends StatelessWidget {
  const LifeFaithScreen({super.key});

  void _soon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label — bientôt disponible'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final cards = <_LifeCard>[
      _LifeCard('👥', 'Mouvements', const [Color(0xFF0D3B66), Color(0xFF1A6B9E)],
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MovementsScreen()))),
      _LifeCard('📖', 'Liturgie', const [Color(0xFF1F7A55), Color(0xFF2FA173)],
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LiturgyTodayScreen()))),
      _LifeCard('✝️', 'Évangile', const [Color(0xFF8A6D1B), Color(0xFFC6A02C)],
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LiturgyTodayScreen()))),
      _LifeCard('📚', 'Bible', const [Color(0xFF5B3A94), Color(0xFF8258C4)], onTap: () => _soon(context, 'Bible')),
      _LifeCard('🙏', 'Prières', const [Color(0xFF1A6B9E), Color(0xFF3A9BCF)], onTap: () => _soon(context, 'Prières')),
      _LifeCard('📿', 'Chapelets', const [Color(0xFF7A4FB0), Color(0xFF9B6BDD)], onTap: () => _soon(context, 'Chapelets')),
      _LifeCard('👼', 'Saints', const [Color(0xFFB8901E), Color(0xFFE3B94A)], onTap: () => _soon(context, 'Saints')),
      _LifeCard('❤️', 'Intentions', const [Color(0xFFB23030), Color(0xFFD45858)], onTap: () => _soon(context, 'Intentions')),
      _LifeCard('🎓', 'Catéchèse', const [Color(0xFF0D6E63), Color(0xFF1FA493)], onTap: () => _soon(context, 'Catéchèse')),
      _LifeCard('🎧', 'Podcasts', const [Color(0xFF3D3A78), Color(0xFF6B66AA)], onTap: () => _soon(context, 'Podcasts')),
      _LifeCard('🎥', 'Enseignements', const [Color(0xFF7B1A4B), Color(0xFFB2306E)], onTap: () => _soon(context, 'Enseignements')),
    ];

    return Container(
      color: HomePalette.screenBg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        children: [
          const Text('Vie & Foi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: HomePalette.navy)),
          const SizedBox(height: 4),
          const Text('Grandissez chaque jour dans votre foi.', style: TextStyle(fontSize: 14, color: HomePalette.textBody)),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: cards.map((c) => _LifeCardTile(card: c)).toList(),
          ),
        ],
      ),
    );
  }
}

class _LifeCard {
  const _LifeCard(this.emoji, this.label, this.colors, {required this.onTap});
  final String emoji;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;
}

class _LifeCardTile extends StatelessWidget {
  const _LifeCardTile({required this.card});
  final _LifeCard card;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: card.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: card.colors),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: card.colors.last.withValues(alpha: .35), blurRadius: 16, offset: const Offset(0, 8), spreadRadius: -6)],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(card.emoji, style: const TextStyle(fontSize: 30)),
                Text(card.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
