import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/skeleton.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../../home/presentation/widgets/parish_post_card.dart';
import '../data/repositories/announcement_repository_impl.dart';
import 'announcement_detail_screen.dart';
import 'announcement_share.dart';
import 'announcement_visuals.dart';
import 'providers/parish_feed_provider.dart';
import 'saved_announcements_screen.dart';

/// The full "Fil paroissial" — every recent announcement, most recent first.
class AnnouncementListScreen extends ConsumerWidget {
  const AnnouncementListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(parishFeedFullProvider);

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        title: const Text('Fil paroissial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Mes annonces enregistrées',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedAnnouncementsScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: HomePalette.navy,
        onRefresh: () async => ref.invalidate(parishFeedFullProvider),
        child: async.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [SkeletonFeedCard(), SizedBox(height: 14), SkeletonFeedCard()],
          ),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              ErrorState(
                message: e is ApiException ? e.message : 'Impossible de charger le fil paroissial.',
                onRetry: () => ref.invalidate(parishFeedFullProvider),
              ),
            ],
          ),
          data: (posts) => posts.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: const [EmptyState(message: 'Aucune annonce pour le moment.', icon: Icons.forum_outlined)],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: posts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final post = posts[i];
                    final visual = AnnouncementVisual.forCategory(post.category);
                    return ParishPostCard(
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
                      isSaved: post.isSaved,
                      isLiked: post.isLiked,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AnnouncementDetailScreen(announcement: post))),
                      onShare: () => shareAnnouncement(post),
                      onToggleSave: () => ref.read(announcementRemoteDataSourceProvider).toggleSave(post.id),
                      onToggleLike: () => ref.read(announcementRemoteDataSourceProvider).toggleLike(post.id),
                    ).animate().fadeIn(duration: 260.ms, delay: (i.clamp(0, 8) * 40).ms);
                  },
                ),
        ),
      ),
    );
  }
}
