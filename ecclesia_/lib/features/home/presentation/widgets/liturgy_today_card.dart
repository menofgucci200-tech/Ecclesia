import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

/// "Liturgie du jour" hero card with a live countdown to the next mass,
/// reproducing the navy gradient card at the top of the home dashboard.
class LiturgyTodayCard extends StatefulWidget {
  const LiturgyTodayCard({super.key, this.onSeeLiturgy});

  final VoidCallback? onSeeLiturgy;

  @override
  State<LiturgyTodayCard> createState() => _LiturgyTodayCardState();
}

class _LiturgyTodayCardState extends State<LiturgyTodayCard> {
  // Mass times used by the mockup: 09:30, 11:00, 18:30.
  static const List<(int, int)> _massTimes = [(9, 30), (11, 0), (18, 30)];

  Timer? _timer;
  String _countdown = '—h —min';

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now();
    DateTime? next;
    for (final (h, m) in _massTimes) {
      final candidate = DateTime(now.year, now.month, now.day, h, m);
      if (candidate.isAfter(now)) {
        next = candidate;
        break;
      }
    }
    final String value;
    if (next == null) {
      value = 'Terminé';
    } else {
      final diff = next.difference(now);
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      final s = diff.inSeconds % 60;
      value = h > 0
          ? '${h}h ${m.toString().padLeft(2, '0')}min'
          : '${m}min ${s.toString().padLeft(2, '0')}s';
    }
    if (mounted && value != _countdown) {
      setState(() => _countdown = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HomePalette.navy, HomePalette.navyDeep],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: HomePalette.navy.withValues(alpha:.6),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'DIMANCHE · 6 JUILLET 2026',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: HomePalette.gold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: HomePalette.gold.withValues(alpha:.25))),
              const SizedBox(width: 8),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(color: HomePalette.green, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              const Text(
                'Ordinaire',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: HomePalette.green),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '14ᵉ Dimanche du Temps Ordinaire',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -.3,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [HomePalette.gold.withValues(alpha:.5), HomePalette.gold.withValues(alpha:.08)],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _InfoTile(label: 'ÉVANGILE', value: 'Lc 10, 1-12', sub: 'Mission des 72')),
              SizedBox(width: 10),
              Expanded(child: _InfoTile(label: 'SAINT DU JOUR', value: 'Saint Goar', sub: 'Ermite, IVᵉ s.')),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withValues(alpha:.07)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROCHAINE MESSE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .7,
                      color: Colors.white.withValues(alpha:.45),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '09h30',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                      letterSpacing: -.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: HomePalette.gold.withValues(alpha:.18),
                  border: Border.all(color: HomePalette.gold.withValues(alpha:.4)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      'dans',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha:.5)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _countdown,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: HomePalette.gold,
                        letterSpacing: -.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: widget.onSeeLiturgy,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: HomePalette.gold.withValues(alpha:.55), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: HomePalette.gold,
                padding: EdgeInsets.zero,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Voir toute la liturgie',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HomePalette.gold),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 15, color: HomePalette.gold),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, required this.sub});

  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: .8, color: HomePalette.gold),
          ),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha:.5))),
        ],
      ),
    );
  }
}
