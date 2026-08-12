import 'package:flutter/material.dart';

import '../../../../core/widgets/fade_network_image.dart';
import '../theme/home_palette.dart';

/// A single post in the "Fil paroissial" feed: a coloured header image
/// placeholder, title/body, author line, and — optionally — an interactive
/// like / comment / share / save action row.
class ParishPostCard extends StatefulWidget {
  const ParishPostCard({
    super.key,
    required this.category,
    required this.categoryColor,
    required this.headerColors,
    required this.headerIcon,
    required this.headerHeight,
    required this.title,
    required this.body,
    required this.authorInitials,
    required this.authorColor,
    required this.authorName,
    required this.date,
    this.imageUrl,
    this.showActions = true,
    this.initialLikeCount = 24,
    this.commentCount = 8,
    this.isSaved = false,
    this.isLiked = false,
    this.onShare,
    this.onTap,
    this.onToggleSave,
    this.onToggleLike,
  });

  final String category;
  final Color categoryColor;
  final List<Color> headerColors;
  final IconData headerIcon;
  final double headerHeight;
  final String title;
  final String body;
  final String authorInitials;
  final Color authorColor;
  final String authorName;
  final String date;
  final String? imageUrl;
  final bool showActions;
  final int initialLikeCount;
  final int commentCount;
  final bool isSaved;
  final bool isLiked;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  /// Persists the bookmark toggle server-side and returns the resulting
  /// state. The card updates optimistically and rolls back on failure.
  final Future<bool> Function()? onToggleSave;

  /// Persists the like toggle server-side and returns the resulting state +
  /// the real like count. Optimistic, rolls back on failure.
  final Future<({bool isLiked, int likesCount})> Function()? onToggleLike;

  @override
  State<ParishPostCard> createState() => _ParishPostCardState();
}

class _ParishPostCardState extends State<ParishPostCard> {
  late bool _saved = widget.isSaved;
  bool _saveBusy = false;

  late bool _liked = widget.isLiked;
  late int _likeCount = widget.initialLikeCount;
  bool _likeBusy = false;

  Future<void> _toggleSave() async {
    if (widget.onToggleSave == null || _saveBusy) return;
    setState(() {
      _saveBusy = true;
      _saved = !_saved;
    });
    try {
      final result = await widget.onToggleSave!();
      if (mounted) setState(() => _saved = result);
    } catch (_) {
      if (mounted) setState(() => _saved = !_saved);
    } finally {
      if (mounted) setState(() => _saveBusy = false);
    }
  }

  Future<void> _toggleLike() async {
    if (widget.onToggleLike == null || _likeBusy) return;
    setState(() {
      _likeBusy = true;
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
    try {
      final result = await widget.onToggleLike!();
      if (mounted) {
        setState(() {
          _liked = result.isLiked;
          _likeCount = result.likesCount;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _liked = !_liked;
          _likeCount += _liked ? 1 : -1;
        });
      }
    } finally {
      if (mounted) setState(() => _likeBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomePalette.cardBg,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
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
              SizedBox(
                height: widget.headerHeight,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.headerColors,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        widget.headerIcon,
                        size: widget.headerHeight > 130 ? 44 : 36,
                        color: Colors.white.withValues(alpha: .22),
                      ),
                    ),
                    if (widget.imageUrl != null &&
                        widget.imageUrl!.isNotEmpty) ...[
                      Positioned.fill(
                        child: FadeNetworkImage(
                          url: widget.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Keeps the category badge legible over a bright photo.
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: .28),
                                Colors.transparent,
                                Colors.black.withValues(alpha: .12),
                              ],
                              stops: const [0, .4, 1],
                            ),
                          ),
                        ),
                      ),
                    ],
                    Positioned(
                      top: 12,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .3),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          widget.category,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: widget.categoryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: HomePalette.navy,
                        height: 1.3,
                        letterSpacing: -.2,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      widget.body,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.6,
                        color: HomePalette.textBody,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: widget.authorColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.authorInitials,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.authorName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: HomePalette.textAuthor,
                                  ),
                                ),
                                TextSpan(
                                  text: '  · ${widget.date}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: HomePalette.textFaint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.showActions) ...[
                      const SizedBox(height: 10),
                      Container(height: 1, color: HomePalette.hairline),
                      const SizedBox(height: 9),
                      _buildActions(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _ActionButton(
          icon: _liked ? Icons.favorite : Icons.favorite_border,
          color: _liked ? HomePalette.red : HomePalette.textMuted,
          label: '$_likeCount',
          onTap: _toggleLike,
        ),
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          color: HomePalette.textMuted,
          label: '${widget.commentCount}',
          onTap: widget.onTap,
        ),
        _ActionButton(
          icon: Icons.share_outlined,
          color: HomePalette.textMuted,
          label: 'Partager',
          onTap: widget.onShare,
        ),
        _ActionButton(
          icon: _saved ? Icons.bookmark : Icons.bookmark_border,
          color: _saved ? HomePalette.gold : HomePalette.textMuted,
          onTap: _toggleSave,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    this.label,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              if (label != null) ...[
                const SizedBox(width: 5),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
