import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/fade_network_image.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/models/announcement_comment_model.dart';
import '../data/models/announcement_model.dart';
import '../data/repositories/announcement_repository_impl.dart';
import 'announcement_share.dart';
import 'announcement_visuals.dart';
import 'providers/parish_feed_provider.dart';

/// Full-screen reading view for a single parish announcement — opened from
/// "Lire l'annonce" (priority card) or by tapping any post in the feed.
/// Hosts the comment thread and the "enregistrer" (bookmark) action.
class AnnouncementDetailScreen extends ConsumerStatefulWidget {
  const AnnouncementDetailScreen({super.key, required this.announcement});

  final AnnouncementModel announcement;

  @override
  ConsumerState<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState
    extends ConsumerState<AnnouncementDetailScreen> {
  late bool _liked = widget.announcement.isLiked;
  late int _likeCount = widget.announcement.likesCount;
  bool _likeBusy = false;
  late bool _saved = widget.announcement.isSaved;
  bool _saveBusy = false;

  final _commentController = TextEditingController();
  bool _postingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleSave() async {
    if (_saveBusy) return;
    setState(() {
      _saveBusy = true;
      _saved = !_saved;
    });
    HapticFeedback.selectionClick();
    try {
      final result = await ref
          .read(announcementRemoteDataSourceProvider)
          .toggleSave(widget.announcement.id);
      if (mounted) setState(() => _saved = result);
    } catch (_) {
      if (mounted) {
        setState(() => _saved = !_saved);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible d'enregistrer cette annonce."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saveBusy = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_likeBusy) return;
    setState(() {
      _likeBusy = true;
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
    HapticFeedback.selectionClick();
    try {
      final result = await ref
          .read(announcementRemoteDataSourceProvider)
          .toggleLike(widget.announcement.id);
      if (mounted) {
        setState(() {
          _liked = result.isLiked;
          _likeCount = result.likesCount;
        });
      }
      ref.invalidate(parishFeedProvider);
      ref.invalidate(parishFeedFullProvider);
      ref.invalidate(savedAnnouncementsProvider);
    } catch (_) {
      if (mounted) {
        setState(() {
          _liked = !_liked;
          _likeCount += _liked ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible d'enregistrer votre réaction."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _likeBusy = false);
    }
  }

  /// Comment counts live in three places (this thread, the feed cards, the
  /// saved list) — all three read the same backend, so all three must be
  /// invalidated together or two of them go stale.
  void _invalidateCommentSources() {
    ref.invalidate(announcementCommentsProvider(widget.announcement.id));
    ref.invalidate(parishFeedProvider);
    ref.invalidate(parishFeedFullProvider);
    ref.invalidate(savedAnnouncementsProvider);
  }

  Future<void> _postComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty || _postingComment) return;
    setState(() => _postingComment = true);
    try {
      await ref
          .read(announcementRemoteDataSourceProvider)
          .postComment(widget.announcement.id, body);
      _commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();
      _invalidateCommentSources();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException
                  ? e.message
                  : "Impossible d'envoyer le commentaire.",
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _postingComment = false);
    }
  }

  Future<void> _deleteComment(AnnouncementCommentModel comment) async {
    try {
      await ref
          .read(announcementRemoteDataSourceProvider)
          .deleteComment(widget.announcement.id, comment.id);
      _invalidateCommentSources();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException
                  ? e.message
                  : 'Impossible de supprimer le commentaire.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.announcement;
    final visual = AnnouncementVisual.forCategory(post.category);
    final hasImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final commentsAsync = ref.watch(announcementCommentsProvider(post.id));

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      // The comment input lives in `body` (not `bottomNavigationBar`, which
      // Flutter does not lift above the keyboard) so it stays visible while typing.
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: hasImage ? 220 : 120,
                  backgroundColor: visual.gradient.first,
                  foregroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    IconButton(
                      icon: Icon(
                        _saved ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      onPressed: _toggleSave,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        shareAnnouncement(post);
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: visual.gradient,
                            ),
                          ),
                        ),
                        if (!hasImage)
                          Center(
                            child: Icon(
                              visual.icon,
                              size: 64,
                              color: Colors.white.withValues(alpha: .22),
                            ),
                          ),
                        if (hasImage)
                          FadeNetworkImage(
                            url: post.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: .1),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: .35),
                                ],
                                stops: const [0, .5, 1],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: visual.badgeColor.withValues(alpha: .5),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            post.categoryLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: HomePalette.navy,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: HomePalette.navy,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: visual.authorColor,
                              child: Text(
                                post.authorInitials,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.authorName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: HomePalette.navy,
                                    ),
                                  ),
                                  if (post.authorRole != null)
                                    Text(
                                      post.authorRole!,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: HomePalette.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              post.shortDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: HomePalette.textFaint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          post.body,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: Color(0xFF3A4657),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(height: 1, color: HomePalette.hairline),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _toggleLike,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _liked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 18,
                                      color: _liked
                                          ? HomePalette.red
                                          : HomePalette.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$_likeCount',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: HomePalette.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 17,
                              color: HomePalette.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              // Real count only — never the announcement's
                              // possibly-stale denormalized counter.
                              commentsAsync.asData?.value.length.toString() ??
                                  '…',
                              style: const TextStyle(
                                fontSize: 13,
                                color: HomePalette.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Commentaires',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: HomePalette.navy,
                          ),
                        ),
                        const SizedBox(height: 12),
                        commentsAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: HomePalette.navy,
                              ),
                            ),
                          ),
                          error: (e, _) => Text(
                            e is ApiException
                                ? e.message
                                : 'Impossible de charger les commentaires.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: HomePalette.textMuted,
                            ),
                          ),
                          data: (comments) => comments.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Aucun commentaire pour le moment. Soyez le premier à réagir.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: HomePalette.textMuted,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (final c in comments)
                                      _CommentTile(
                                        comment: c,
                                        onDelete: () => _deleteComment(c),
                                      ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: HomePalette.hairline)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _postComment(),
                      decoration: InputDecoration(
                        hintText: 'Ajouter un commentaire…',
                        filled: true,
                        fillColor: HomePalette.screenBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _postingComment
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          onPressed: _postComment,
                          icon: const Icon(Icons.send_rounded),
                          color: HomePalette.navy,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.onDelete});

  final AnnouncementCommentModel comment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: HomePalette.navy.withValues(alpha: .12),
            backgroundImage: comment.authorAvatarUrl != null
                ? NetworkImage(comment.authorAvatarUrl!)
                : null,
            child: comment.authorAvatarUrl == null
                ? Text(
                    comment.authorInitials,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: HomePalette.navy,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: HomePalette.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          comment.authorName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: HomePalette.navy,
                          ),
                        ),
                      ),
                      Text(
                        comment.relativeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: HomePalette.textFaint,
                        ),
                      ),
                      if (comment.isMine) ...[
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: onDelete,
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: HomePalette.textFaint,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    comment.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF3A4657),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
