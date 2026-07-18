import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../router/app_routes.dart';
import '../../../announcement/data/models/announcement_model.dart';
import '../../../announcement/presentation/announcement_visuals.dart';
import '../../../announcement/presentation/providers/parish_feed_provider.dart';
import '../providers/home_provider.dart';
import '../screens/liturgy_screen.dart';
import '../theme/home_palette.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_sections.dart';
import '../widgets/liturgy_today_card.dart';
import '../widgets/parish_post_card.dart';

/// The authenticated home dashboard reproducing the "Ecran8 Accueil" mockup:
/// liturgy of the day, priority announcement, parish feed, upcoming events,
/// activities, an ongoing collection and the quote of the day.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  void _comingSoon([String? label]) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(label == null ? 'Bientôt disponible' : '$label — bientôt disponible'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _onTab(int index) {
    if (index == _tab) return;
    // Profil already exists as its own screen; the rest are placeholders.
    if (index == 4) {
      context.push(AppRoutes.profile);
      return;
    }
    setState(() => _tab = index);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: HomePalette.screenBg,
        body: Column(
          children: [
            _HomeAppBar(
              notifCount: 3,
              // Home is the root of the authenticated experience (reached via
              // `context.go`), so there is nothing to pop. The back arrow
              // returns to the "Bienvenue" screen instead.
              onBack: () => context.go(AppRoutes.welcomeUser),
              onNotif: () => _comingSoon('Notifications'),
            ),
            Expanded(
              child: _tab == 0 ? _HomeFeed(onComingSoon: _comingSoon) : _TabPlaceholder(index: _tab),
            ),
          ],
        ),
        bottomNavigationBar: HomeBottomNav(currentIndex: _tab, onTap: _onTab),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.notifCount, required this.onBack, required this.onNotif});

  final int notifCount;
  final VoidCallback onBack;
  final VoidCallback onNotif;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      color: HomePalette.gold,
      padding: EdgeInsets.only(top: topInset),
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _IconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
              const Expanded(
                child: Center(
                  child: Text(
                    'ECCLESIA',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2),
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _IconButton(icon: Icons.notifications_none, onTap: onNotif),
                  if (notifCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 17,
                        height: 17,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: HomePalette.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          '$notifCount',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white, height: 1),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      iconSize: 22,
      color: Colors.white,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      splashRadius: 22,
    );
  }
}

class _HomeFeed extends ConsumerWidget {
  const _HomeFeed({required this.onComingSoon});

  final void Function([String?]) onComingSoon;

  static const EdgeInsets _hpad = EdgeInsets.symmetric(horizontal: 18);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(parishFeedProvider);
    final home = ref.watch(homeProvider).asData?.value;

    return RefreshIndicator(
      color: HomePalette.navy,
      onRefresh: () async {
        ref.invalidate(homeProvider);
        ref.invalidate(parishFeedProvider);
        await ref.read(parishFeedProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: _hpad,
            child: LiturgyTodayCard(
              liturgy: home?.liturgy,
              nextMass: home?.nextMass,
              onSeeLiturgy: home?.liturgy == null
                  ? () => onComingSoon('Liturgie du jour')
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LiturgyScreen(liturgy: home!.liturgy!)),
                      ),
            ),
          ),
          const SizedBox(height: 18),
          ..._feedSection(ref, feedAsync),
          const SizedBox(height: 20),
          Padding(
            padding: _hpad,
            child: SectionHeader(title: 'Événements à venir', onSeeAll: () => onComingSoon('Événements')),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: _hpad,
            child: const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EventMiniCard(
                    headerColors: [Color(0xFF7B1A1A), Color(0xFFB23030), Color(0xFFD45858)],
                    icon: Icons.calendar_today_outlined,
                    dateLabel: '12 juil. · 10h00',
                    accent: Color(0xFFB23030),
                    title: 'Fête patronale',
                    place: 'Cathédrale',
                    badgeText: 'Dans 6 jours',
                    badgeBg: Color(0xFFFEF2F2),
                  ),
                  SizedBox(width: 12),
                  EventMiniCard(
                    headerColors: [Color(0xFF3D1A78), Color(0xFF6B3AAA), Color(0xFF9B6BDD)],
                    icon: Icons.music_note,
                    dateLabel: '19 juil. · 18h00',
                    accent: Color(0xFF6B3AAA),
                    title: 'Concert de la chorale',
                    place: 'Salle paroissiale',
                    badgeText: 'Dans 13 jours',
                    badgeBg: Color(0xFFF5EEFF),
                  ),
                  SizedBox(width: 12),
                  EventMiniCard(
                    headerColors: [Color(0xFF0D3B66), Color(0xFF1A6B9E), Color(0xFF3A9BCF)],
                    icon: Icons.home_outlined,
                    dateLabel: '2 août · 6h00',
                    accent: Color(0xFF1A6B9E),
                    title: 'Pèlerinage Yamoussoukro',
                    place: 'Bus paroissial',
                    badgeText: 'Dans 27 jours',
                    badgeBg: Color(0xFFEEF5FB),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: _hpad,
            child: SectionHeader(title: 'Mes activités', onSeeAll: () => onComingSoon('Mes activités')),
          ),
          const SizedBox(height: 12),
          const Padding(padding: _hpad, child: MyActivitiesCard()),
          const SizedBox(height: 18),
          Padding(
            padding: _hpad,
            child: CollectionCard(onDonate: () => onComingSoon('Faire un don')),
          ),
          const SizedBox(height: 18),
          const Padding(padding: _hpad, child: QuoteCard()),
        ],
      ),
    );
  }

  /// The priority announcement + "Fil paroissial" block, driven by the API.
  List<Widget> _feedSection(WidgetRef ref, AsyncValue<List<AnnouncementModel>> feedAsync) {
    return feedAsync.when(
      loading: () => const [
        Padding(padding: _hpad, child: SectionHeader(title: 'Fil paroissial')),
        SizedBox(height: 12),
        Padding(padding: _hpad, child: _FeedLoader()),
      ],
      error: (error, _) => [
        const Padding(padding: _hpad, child: SectionHeader(title: 'Fil paroissial')),
        const SizedBox(height: 12),
        Padding(
          padding: _hpad,
          child: _FeedError(
            message: error is ApiException ? error.message : 'Impossible de charger le fil paroissial.',
            onRetry: () => ref.invalidate(parishFeedProvider),
          ),
        ),
      ],
      data: (items) {
        AnnouncementModel? priority;
        final posts = <AnnouncementModel>[];
        for (final item in items) {
          if (item.isImportant && priority == null) {
            priority = item;
          } else {
            posts.add(item);
          }
        }

        final children = <Widget>[];

        if (priority != null) {
          children
            ..add(Padding(
              padding: _hpad,
              child: PriorityAnnouncementCard(
                title: priority.title,
                body: priority.body,
                timeLabel: priority.relativeLabel,
                onRead: () => onComingSoon("Lire l'annonce"),
              ),
            ))
            ..add(const SizedBox(height: 18));
        }

        children
          ..add(Padding(
            padding: _hpad,
            child: SectionHeader(title: 'Fil paroissial', onSeeAll: () => onComingSoon('Fil paroissial')),
          ))
          ..add(const SizedBox(height: 12));

        if (posts.isEmpty) {
          children.add(const Padding(padding: _hpad, child: _FeedEmpty()));
        } else {
          for (var i = 0; i < posts.length; i++) {
            final post = posts[i];
            final visual = AnnouncementVisual.forCategory(post.category);
            children.add(Padding(
              padding: _hpad,
              child: ParishPostCard(
                category: post.categoryLabel,
                categoryColor: visual.badgeColor,
                headerColors: visual.gradient,
                headerIcon: visual.icon,
                headerHeight: 148,
                title: post.title,
                body: post.body,
                authorInitials: post.authorInitials,
                authorColor: visual.authorColor,
                authorName: post.authorName,
                date: post.shortDate,
                initialLikeCount: post.likesCount,
                commentCount: post.commentsCount,
                onShare: () => onComingSoon('Partager'),
              ),
            ));
            if (i < posts.length - 1) {
              children.add(const SizedBox(height: 14));
            }
          }
        }

        return children;
      },
    );
  }
}

class _FeedLoader extends StatelessWidget {
  const _FeedLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(child: CircularProgressIndicator(color: HomePalette.navy)),
    );
  }
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HomePalette.cardBg,
        border: Border.all(color: HomePalette.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: HomePalette.textMuted, size: 30),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: HomePalette.textAuthor),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: HomePalette.navy,
              side: const BorderSide(color: HomePalette.navy),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Réessayer', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _FeedEmpty extends StatelessWidget {
  const _FeedEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: HomePalette.cardBg,
        border: Border.all(color: HomePalette.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.forum_outlined, color: HomePalette.textMuted, size: 30),
          SizedBox(height: 10),
          Text(
            'Aucune annonce pour le moment.',
            style: TextStyle(fontSize: 13, color: HomePalette.textAuthor),
          ),
        ],
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.index});

  final int index;

  static const List<String> _titles = ['Accueil', 'Vie & Foi', 'Paiements', 'Agenda', 'Profil'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_empty, size: 40, color: HomePalette.textMuted),
          const SizedBox(height: 12),
          Text(
            '${_titles[index]} — bientôt disponible',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: HomePalette.textAuthor),
          ),
        ],
      ),
    );
  }
}
