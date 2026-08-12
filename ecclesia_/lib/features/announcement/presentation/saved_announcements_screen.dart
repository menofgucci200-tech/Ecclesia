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

/// The faithful's bookmarked announcements — stored server-side
/// (`announcement_saves` table), tied to their account, not the device.
class SavedAnnouncementsScreen extends ConsumerWidget {
  const SavedAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savedAnnouncementsProvider);

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(title: const Text('Annonces enregistrées')),
      body: RefreshIndicator(
        color: HomePalette.navy,
        onRefresh: () async => ref.invalidate(savedAnnouncementsProvider),
        child: async.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [SkeletonFeedCard()],
          ),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              ErrorState(
                message: e is ApiException ? e.message : 'Impossible de charger vos annonces enregistrées.',
                onRetry: () => ref.invalidate(savedAnnouncementsProvider),
              ),
            ],
          ),
          data: (posts) => posts.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: const [
                    EmptyState(
                      message: 'Aucune annonce enregistrée. Touchez l\'icône 🔖 sur une annonce pour la retrouver ici.',
                      icon: Icons.bookmark_border,
                    ),
                  ],
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
                      onToggleSave: () async {
                        final result = await ref.read(announcementRemoteDataSourceProvider).toggleSave(post.id);
                        ref.invalidate(savedAnnouncementsProvider);
                        return result;
                      },
                      onToggleLike: () => ref.read(announcementRemoteDataSourceProvider).toggleLike(post.id),
                    ).animate().fadeIn(duration: 260.ms, delay: (i.clamp(0, 8) * 40).ms);
                  },
                ),
        ),
      ),
    );
  }
}
