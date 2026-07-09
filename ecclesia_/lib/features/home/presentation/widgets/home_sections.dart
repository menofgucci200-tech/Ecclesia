import 'package:flutter/material.dart';

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
class EventMiniCard extends StatelessWidget {
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
  });

  final List<Color> headerColors;
  final IconData icon;
  final String dateLabel;
  final Color accent;
  final String title;
  final String place;
  final String badgeText;
  final Color badgeBg;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: headerColors),
              ),
              child: Center(child: Icon(icon, size: 28, color: Colors.white.withValues(alpha: .3))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel.toUpperCase(),
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: .5, color: accent),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: HomePalette.navy, height: 1.3),
                ),
                const SizedBox(height: 3),
                Text(place, style: const TextStyle(fontSize: 10.5, color: HomePalette.textMuted)),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    badgeText,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: accent),
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

/// "Mes activités" card: two rows with confirmation-status badges.
class MyActivitiesCard extends StatelessWidget {
  const MyActivitiesCard({super.key});

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
            color: HomePalette.navy.withValues(alpha: .08),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -4,
          ),
        ],
      ),
      child: const Column(
        children: [
          _ActivityRow(
            icon: Icons.music_note,
            iconBg: Color(0xFFF0F4FC),
            iconColor: HomePalette.navy,
            title: 'Répétition de chorale',
            subtitle: 'Mer. 8 juil. · 18h00 · Salle Saint-Pierre',
            status: 'Confirmé',
            statusColor: Color(0xFF2E7D32),
            statusBg: Color(0xFFE8F5E9),
            divider: true,
          ),
          _ActivityRow(
            icon: Icons.groups_outlined,
            iconBg: Color(0xFFFDF8EC),
            iconColor: Color(0xFFB9942A),
            title: "Réunion des servants d'autel",
            subtitle: 'Sam. 11 juil. · 10h00 · Sacristie',
            status: 'En attente',
            statusColor: Color(0xFFB9942A),
            statusBg: Color(0xFFFDF8EC),
            divider: false,
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.divider,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        border: divider ? const Border(bottom: BorderSide(color: HomePalette.hairline)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: HomePalette.navy, letterSpacing: -.1),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: HomePalette.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ],
      ),
    );
  }
}

/// "Collecte en cours" card with a progress bar and donation CTA.
class CollectionCard extends StatelessWidget {
  const CollectionCard({super.key, this.onDonate});

  final VoidCallback? onDonate;

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
            color: HomePalette.navy.withValues(alpha: .08),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 82,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D3B66), Color(0xFF1A5F9E), Color(0xFF2A80C8)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COLLECTE EN COURS',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: .7, color: HomePalette.gold.withValues(alpha: .85)),
                ),
                const SizedBox(height: 3),
                const Text(
                  "Rénovation de l'orgue",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -.2),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '5 525 000 FCFA collectés',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF3A4A5A)),
                    ),
                    Text('65%', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: SizedBox(
                    height: 7,
                    child: Stack(
                      children: [
                        const Positioned.fill(child: ColoredBox(color: HomePalette.cardBorder)),
                        const FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: .65,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [HomePalette.navy, HomePalette.gold]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Objectif : 8 500 000 FCFA', style: TextStyle(fontSize: 11, color: HomePalette.textMuted)),
                    Text('142 donateurs', style: TextStyle(fontSize: 11, color: HomePalette.textMuted)),
                  ],
                ),
                const SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onDonate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HomePalette.navy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 15, color: Colors.white),
                        SizedBox(width: 7),
                        Text('Faire un don', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
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
