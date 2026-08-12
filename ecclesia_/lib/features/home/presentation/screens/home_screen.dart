import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/fade_network_image.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../router/app_routes.dart';
import '../../../announcement/data/models/announcement_model.dart';
import '../../../announcement/presentation/announcement_visuals.dart';
import '../../../announcement/presentation/providers/parish_feed_provider.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../../donations/data/campaign.dart';
import '../../../donations/presentation/campaign_providers.dart';
import '../../../donations/presentation/donations_screen.dart' show CampaignCard;
import '../../../movements/data/models/movement.dart';
import '../../../movements/presentation/providers/movements_provider.dart';
import '../../../payments/presentation/payments_hub_screen.dart';
import '../../../movements/presentation/screens/movement_detail_screen.dart';
import '../../../movements/presentation/screens/movements_screen.dart';
import '../../../notifications/data/notification_providers.dart';
import '../../../notifications/presentation/notifications_screen.dart';
import '../../data/models/home_data.dart';
import '../providers/home_provider.dart';
import '../screens/liturgy_screen.dart';
import '../theme/home_palette.dart';
import '../theme/liturgical_colors.dart';
import '../widgets/agenda_view.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_end_drawer.dart';
import '../widgets/home_sections.dart';
import '../widgets/liturgy_today_card.dart';
import '../widgets/parish_post_card.dart';

/// The authenticated home dashboard reproducing the "Ecran8 Accueil" mockup:
/// liturgy of the day, priority announcement, parish feed, upcoming events,
/// activities, an ongoing collection and the quote of the day.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
    // "Menu" (index 4) is an action button, not a persistent tab: it opens
    // the end drawer and never becomes the active tab.
    if (index == 4) {
      HapticFeedback.selectionClick();
      _scaffoldKey.currentState?.openEndDrawer();
      return;
    }
    if (index == _tab) return;
    HapticFeedback.selectionClick();
    setState(() => _tab = index);
  }

  Future<void> _openNotifications(BuildContext context) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    // The screen marks everything read on open; refresh the badge on return.
    if (mounted) ref.invalidate(unreadNotificationsCountProvider);
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeProvider).asData?.value;
    final season = LiturgicalColors.season(home?.liturgy?.season, home?.liturgy?.color);
    final unreadCount = ref.watch(unreadNotificationsCountProvider).asData?.value ?? 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: HomePalette.screenBg,
        endDrawer: const HomeEndDrawer(),
        body: Column(
          children: [
            _HomeAppBar(
              notifCount: unreadCount,
              barColor: season.primary,
              seasonName: season.name,
              // Home is the root of the authenticated experience (reached via
              // `context.go`), so there is nothing to pop. The back arrow
              // returns to the "Bienvenue" screen instead.
              onBack: () => context.go(AppRoutes.welcomeUser),
              onNotif: () => _openNotifications(context),
            ),
            const OfflineBanner(),
            Expanded(
              child: switch (_tab) {
                0 => _HomeFeed(
                    onComingSoon: _comingSoon,
                    onSeeMovements: () => setState(() => _tab = 1),
                    onSeePaiements: () => setState(() => _tab = 2),
                  ),
                1 => const MovementsScreen(),
                2 => const PaymentsHubScreen(),
                3 => AgendaView(seasonColor: season.primary),
                _ => _TabPlaceholder(index: _tab),
              },
            ),
          ],
        ),
        bottomNavigationBar: HomeBottomNav(
          currentIndex: _tab,
          onTap: _onTab,
          activeColor: season.primary,
          avatarUrl: ref.watch(currentUserProvider)?.avatarUrl,
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({
    required this.notifCount,
    required this.onBack,
    required this.onNotif,
    this.barColor = HomePalette.gold,
    this.seasonName = '',
  });

  final int notifCount;
  final Color barColor;
  final String seasonName;
  final VoidCallback onBack;
  final VoidCallback onNotif;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      color: barColor,
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

/// A chip for one of the faithful's movements, shown in "Mes activités".
class _MyMovementChip extends StatelessWidget {
  const _MyMovementChip({required this.movement});

  final Movement movement;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MovementDetailScreen(id: movement.id, name: movement.name)),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HomePalette.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HomePalette.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40, clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: HomePalette.navy.withValues(alpha: .08), borderRadius: BorderRadius.circular(11)),
              child: FadeNetworkImage(
                url: movement.logoUrl,
                fallback: const Icon(Icons.groups_outlined, size: 20, color: HomePalette.navy),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movement.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: HomePalette.navy)),
                  Text(movement.category ?? 'Mouvement', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: HomePalette.textBody)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds a compact "upcoming event" card from a real agenda item.
Widget _eventCardFrom(AgendaEvent e, {VoidCallback? onTap}) {
  const monthsAbbr = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
  final now = DateTime.now();
  final days = DateTime(e.date.year, e.date.month, e.date.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
  final badge = days <= 0 ? "Aujourd'hui" : days == 1 ? 'Demain' : 'Dans $days jours';
  final dateLabel = '${e.date.day} ${monthsAbbr[e.date.month - 1]}${e.time != null ? ' · ${e.time}' : ''}';
  final isParish = e.isParish;

  return EventMiniCard(
    headerColors: isParish
        ? const [Color(0xFF0D3B66), Color(0xFF1A6B9E), Color(0xFF3A9BCF)]
        : const [Color(0xFF7A5C10), Color(0xFFB8901E), Color(0xFFD4AF37)],
    icon: isParish ? Icons.groups_outlined : Icons.church_outlined,
    dateLabel: dateLabel,
    accent: isParish ? const Color(0xFF1A6B9E) : const Color(0xFFB8901E),
    title: e.title,
    place: e.location ?? e.subtitle ?? (isParish ? 'Paroisse' : 'Fête liturgique'),
    badgeText: badge,
    badgeBg: isParish ? const Color(0xFFEEF5FB) : const Color(0xFFFBF3DD),
    onTap: onTap,
  );
}

class _HomeFeed extends ConsumerWidget {
  const _HomeFeed({required this.onComingSoon, required this.onSeeMovements, required this.onSeePaiements});

  final void Function([String?]) onComingSoon;
  final VoidCallback onSeeMovements;
  final VoidCallback onSeePaiements;

  static const EdgeInsets _hpad = EdgeInsets.symmetric(horizontal: 18);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(parishFeedProvider);
    final homeAsync = ref.watch(homeProvider);
    final home = homeAsync.asData?.value;
    final myMovementsAsync = ref.watch(myMovementsProvider);
    final myMovements = myMovementsAsync.asData?.value ?? const <Movement>[];
    final user = ref.watch(currentUserProvider);
    final hidden = user?.hiddenSections ?? const <String>[];
    final movementsFirst = user?.feedPriority == 'movements';
    final campaigns = ref.watch(campaignsProvider).asData?.value ?? const <Campaign>[];

    // "Mes activités" (movements) block — placed first when the user prioritises it.
    final activitiesBlock = <Widget>[
      const SizedBox(height: 20),
      Padding(
        padding: _hpad,
        child: SectionHeader(
          title: 'Mes activités',
          onSeeAll: onSeeMovements,
        ),
      ),
      const SizedBox(height: 12),
      if (myMovementsAsync.isLoading)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: _hpad,
          child: Row(
            children: const [
              SkeletonBox(width: 180, height: 64, radius: 16),
              SizedBox(width: 12),
              SkeletonBox(width: 180, height: 64, radius: 16),
            ],
          ),
        )
      else if (myMovements.isEmpty)
        Padding(
          padding: _hpad,
          child: Text('Rejoignez un mouvement dans « Vie & Foi » pour le retrouver ici.',
              style: const TextStyle(fontSize: 13, color: HomePalette.textBody)),
        )
      else
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: _hpad,
          child: Row(
            children: [
              for (final (i, m) in myMovements.indexed) ...[
                _MyMovementChip(movement: m)
                    .animate()
                    .fadeIn(duration: 280.ms, delay: (i * 50).ms)
                    .slideX(begin: .08, end: 0, duration: 280.ms, delay: (i * 50).ms, curve: Curves.easeOutCubic),
                const SizedBox(width: 12),
              ],
            ],
          ),
        ),
    ];

    return RefreshIndicator(
      color: HomePalette.navy,
      onRefresh: () async {
        ref.invalidate(homeProvider);
        ref.invalidate(myMovementsProvider);
        ref.invalidate(parishFeedProvider);
        await ref.read(parishFeedProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          const SizedBox(height: 18),
          if (!hidden.contains('liturgy'))
            Padding(
              padding: _hpad,
              child: homeAsync.isLoading
                  ? const SkeletonBox(width: double.infinity, height: 180, radius: 20)
                  : LiturgyTodayCard(
                      liturgy: home?.liturgy,
                      nextMass: home?.nextMass,
                      onSeeLiturgy: home?.liturgy == null
                          ? () => onComingSoon('Liturgie du jour')
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => LiturgyScreen(liturgy: home!.liturgy!)),
                              ),
                    ).animate().fadeIn(duration: 340.ms).slideY(begin: .05, end: 0, duration: 340.ms, curve: Curves.easeOutCubic),
            ),
          // "Mes activités" first when the user prioritises their movements.
          if (movementsFirst && !hidden.contains('activities')) ...activitiesBlock,
          if (!hidden.contains('feed')) ...[
            const SizedBox(height: 18),
            ..._feedSection(ref, feedAsync),
          ],
          if (!hidden.contains('events')) ...[
            const SizedBox(height: 20),
            Padding(
              padding: _hpad,
              child: SectionHeader(title: 'Événements à venir', onSeeAll: () => onComingSoon('Événements')),
            ),
            const SizedBox(height: 12),
            if (homeAsync.isLoading)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: _hpad,
                child: Row(
                  children: const [
                    SkeletonBox(width: 150, height: 110, radius: 16),
                    SizedBox(width: 12),
                    SkeletonBox(width: 150, height: 110, radius: 16),
                    SizedBox(width: 12),
                    SkeletonBox(width: 150, height: 110, radius: 16),
                  ],
                ),
              )
            else if ((home?.events ?? const []).isEmpty)
              Padding(
                padding: _hpad,
                child: Text('Aucun événement à venir pour le moment.',
                    style: TextStyle(fontSize: 13, color: HomePalette.textBody)),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: _hpad,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, e) in home!.events.take(8).indexed) ...[
                        _eventCardFrom(e, onTap: () => onComingSoon(e.title))
                            .animate()
                            .fadeIn(duration: 300.ms, delay: (i * 60).ms)
                            .slideX(begin: .08, end: 0, duration: 300.ms, delay: (i * 60).ms, curve: Curves.easeOutCubic),
                        const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ),
              ),
          ],
          if (!movementsFirst && !hidden.contains('activities')) ...activitiesBlock,
          if (!hidden.contains('collection') && campaigns.isNotEmpty) ...[
            const SizedBox(height: 20),
            Padding(
              padding: _hpad,
              child: SectionHeader(
                title: 'Dons & collectes',
                onSeeAll: onSeePaiements,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: _hpad,
              child: CampaignCard(campaign: campaigns.first)
                  .animate()
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: .05, end: 0, duration: 320.ms, curve: Curves.easeOutCubic),
            ),
          ],
          if (!hidden.contains('quote')) ...[
            const SizedBox(height: 18),
            Padding(
              padding: _hpad,
              child: const QuoteCard()
                  .animate()
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: .05, end: 0, duration: 320.ms, curve: Curves.easeOutCubic),
            ),
          ],
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
        Padding(padding: _hpad, child: SkeletonFeedCard()),
      ],
      error: (error, _) => [
        const Padding(padding: _hpad, child: SectionHeader(title: 'Fil paroissial')),
        const SizedBox(height: 12),
        Padding(
          padding: _hpad,
          child: ErrorState(
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
              ).animate().fadeIn(duration: 320.ms).slideY(begin: .05, end: 0, duration: 320.ms, curve: Curves.easeOutCubic),
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
          children.add(const Padding(
            padding: _hpad,
            child: EmptyState(message: 'Aucune annonce pour le moment.', icon: Icons.forum_outlined),
          ));
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
                imageUrl: post.imageUrl,
                authorInitials: post.authorInitials,
                authorColor: visual.authorColor,
                authorName: post.authorName,
                date: post.shortDate,
                initialLikeCount: post.likesCount,
                commentCount: post.commentsCount,
                onShare: () => onComingSoon('Partager'),
              )
                  .animate()
                  .fadeIn(duration: 320.ms, delay: (i * 60).ms)
                  .slideY(begin: .06, end: 0, duration: 320.ms, delay: (i * 60).ms, curve: Curves.easeOutCubic),
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

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.index});

  final int index;

  static const List<String> _titles = ['Accueil', 'Mouvements', 'Paiements', 'Agenda', 'Menu'];

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
