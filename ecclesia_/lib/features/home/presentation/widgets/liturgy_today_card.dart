import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/home_data.dart';
import '../theme/home_palette.dart';

/// "Liturgie du jour" hero card, fed by the real liturgy (AELF) and the
/// parish's next mass, with a live countdown to that mass.
class LiturgyTodayCard extends StatefulWidget {
  const LiturgyTodayCard({
    super.key,
    this.liturgy,
    this.nextMass,
    this.onSeeLiturgy,
  });

  final LiturgyModel? liturgy;
  final NextMassModel? nextMass;
  final VoidCallback? onSeeLiturgy;

  @override
  State<LiturgyTodayCard> createState() => _LiturgyTodayCardState();
}

class _LiturgyTodayCardState extends State<LiturgyTodayCard> {
  static const _days = ['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'];
  static const _months = [
    'JANVIER', 'FÉVRIER', 'MARS', 'AVRIL', 'MAI', 'JUIN',
    'JUILLET', 'AOÛT', 'SEPTEMBRE', 'OCTOBRE', 'NOVEMBRE', 'DÉCEMBRE',
  ];

  Timer? _timer;
  String _countdown = '—';

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
    final at = widget.nextMass?.at;
    String value;
    if (at == null) {
      value = '—';
    } else {
      final diff = at.difference(DateTime.now());
      if (diff.isNegative) {
        value = 'En cours';
      } else if (diff.inHours >= 24) {
        value = '${diff.inDays}j ${diff.inHours % 24}h';
      } else if (diff.inHours > 0) {
        value = '${diff.inHours}h ${(diff.inMinutes % 60).toString().padLeft(2, '0')}min';
      } else {
        value = '${diff.inMinutes}min ${(diff.inSeconds % 60).toString().padLeft(2, '0')}s';
      }
    }
    if (mounted && value != _countdown) {
      setState(() => _countdown = value);
    }
  }

  Color get _seasonColor => switch (widget.liturgy?.color) {
        'blanc' => const Color(0xFFE6C34A),
        'rouge' => HomePalette.red,
        'violet' => const Color(0xFF9C6ADE),
        'rose' => const Color(0xFFE38AA8),
        _ => HomePalette.green,
      };

  String get _dateLine {
    final d = widget.liturgy?.date ?? DateTime.now();
    return '${_days[d.weekday - 1]} · ${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final liturgy = widget.liturgy;
    final nextMass = widget.nextMass;

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
            color: HomePalette.navy.withValues(alpha: .6),
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
              Flexible(
                child: Text(
                  _dateLine,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: HomePalette.gold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: HomePalette.gold.withValues(alpha: .25))),
              const SizedBox(width: 8),
              Container(width: 7, height: 7, decoration: BoxDecoration(color: _seasonColor, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(
                _capitalize(liturgy?.season ?? 'Liturgie'),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _seasonColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            liturgy?.liturgicalDay ?? 'Liturgie du jour',
            style: const TextStyle(
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
                colors: [HomePalette.gold.withValues(alpha: .5), HomePalette.gold.withValues(alpha: .08)],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'ÉVANGILE',
                  value: liturgy?.gospelRef ?? '—',
                  sub: liturgy?.gospelTitle ?? '',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  label: 'TEMPS',
                  value: _capitalize(liturgy?.season ?? '—'),
                  sub: liturgy?.week ?? '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withValues(alpha: .07)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextMass == null ? 'HORAIRES DE MESSE' : 'PROCHAINE MESSE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .7,
                        color: Colors.white.withValues(alpha: .45),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextMass?.time ?? 'À définir',
                      style: TextStyle(
                        fontSize: nextMass == null ? 15 : 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                        letterSpacing: -.5,
                      ),
                    ),
                    if (nextMass != null)
                      Text(
                        '${nextMass.dayLabel}${nextMass.label != null ? ' · ${nextMass.label}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .5)),
                      ),
                  ],
                ),
              ),
              if (nextMass != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: HomePalette.gold.withValues(alpha: .18),
                    border: Border.all(color: HomePalette.gold.withValues(alpha: .4)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text('dans', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: .5))),
                      const SizedBox(height: 2),
                      Text(
                        _countdown,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: HomePalette.gold, letterSpacing: -.3),
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
                side: BorderSide(color: HomePalette.gold.withValues(alpha: .55), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: HomePalette.gold,
                padding: EdgeInsets.zero,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Voir les lectures du jour', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HomePalette.gold)),
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

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
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
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: .8, color: HomePalette.gold)),
          const SizedBox(height: 5),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 2),
          Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .5))),
        ],
      ),
    );
  }
}
