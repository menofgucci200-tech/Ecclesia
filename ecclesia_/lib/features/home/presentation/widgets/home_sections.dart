import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/home_palette.dart';

/// Section title with an optional "Voir tout" trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: HomePalette.navy, letterSpacing: -.3),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Voir tout',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: HomePalette.gold),
            ),
          ),
      ],
    );
  }
}

/// High-priority parish announcement with a red/orange accent bar.
class PriorityAnnouncementCard extends StatelessWidget {
  const PriorityAnnouncementCard({
    super.key,
    required this.title,
    required this.body,
    required this.timeLabel,
    this.onRead,
  });

  final String title;
  final String body;
  final String timeLabel;
  final VoidCallback? onRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: HomePalette.cardBg,
        border: Border.all(color: HomePalette.cardBorder),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: HomePalette.navy.withValues(alpha: .09),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFE05252), Color(0xFFE08040)]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'IMPORTANT',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: .7, color: HomePalette.red),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(timeLabel, style: const TextStyle(fontSize: 11.5, color: HomePalette.textFaint)),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: HomePalette.navy, letterSpacing: -.2),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(fontSize: 13, height: 1.6, color: HomePalette.textBody),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: onRead,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: HomePalette.navy, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      foregroundColor: HomePalette.navy,
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Lire l'annonce",
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: HomePalette.navy),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_rounded, size: 13, color: HomePalette.navy),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact, fixed-width event card for the horizontal "Événements à venir" rail.
class EventMiniCard extends StatefulWidget {
  const EventMiniCard({
    super.key,
    required this.headerColors,
    required this.icon,
    required this.dateLabel,
    required this.accent,
    required this.title,
    required this.place,
    required this.badgeText,
    required this.badgeBg,
    this.onTap,
  });

  final List<Color> headerColors;
  final IconData icon;
  final String dateLabel;
  final Color accent;
  final String title;
  final String place;
  final String badgeText;
  final Color badgeBg;
  final VoidCallback? onTap;

  @override
  State<EventMiniCard> createState() => _EventMiniCardState();
}

class _EventMiniCardState extends State<EventMiniCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 155,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: HomePalette.cardBg,
            border: Border.all(color: HomePalette.cardBorder),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: HomePalette.navy.withValues(alpha: .1),
                blurRadius: 10,
                offset: const Offset(0, 2),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 96,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: widget.headerColors),
                  ),
                  child: Center(child: Icon(widget.icon, size: 28, color: Colors.white.withValues(alpha: .3))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dateLabel.toUpperCase(),
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: .5, color: widget.accent),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: HomePalette.navy, height: 1.3),
                    ),
                    const SizedBox(height: 3),
                    Text(widget.place, style: const TextStyle(fontSize: 10.5, color: HomePalette.textMuted)),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: widget.badgeBg, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        widget.badgeText,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: widget.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Citation du jour" card with a warm parchment background.
class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F5EB), Color(0xFFFDF9F0)],
        ),
        border: Border.all(color: const Color(0xFFEDE8D5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(color: HomePalette.gold, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              const Text(
                'CITATION DU JOUR',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .8, color: Color(0xFFB9942A)),
              ),
            ],
          ),
          const SizedBox(height: 11),
          const Text(
            "« La moisson est abondante, mais les ouvriers sont peu nombreux. Priez donc le maître de la moisson d'envoyer des ouvriers. »",
            style: TextStyle(
              fontSize: 14.5,
              height: 1.7,
              color: Color(0xFF3A2E1A),
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 9),
          const Text('— Luc 10, 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFB9942A))),
        ],
      ),
    );
  }
}
