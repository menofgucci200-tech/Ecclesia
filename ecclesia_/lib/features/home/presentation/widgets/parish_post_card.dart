import 'package:flutter/material.dart';

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
    this.showActions = true,
    this.initialLikeCount = 24,
    this.commentCount = 8,
    this.onShare,
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
  final bool showActions;
  final int initialLikeCount;
  final int commentCount;
  final VoidCallback? onShare;

  @override
  State<ParishPostCard> createState() => _ParishPostCardState();
}

class _ParishPostCardState extends State<ParishPostCard> {
  bool _liked = false;
  bool _saved = false;

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
            color: HomePalette.navy.withValues(alpha:.08),
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
                    color: Colors.white.withValues(alpha:.22),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:.3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      widget.category,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: widget.categoryColor),
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
                  style: const TextStyle(fontSize: 12.5, height: 1.6, color: HomePalette.textBody),
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: widget.authorColor, shape: BoxShape.circle),
                      child: Text(
                        widget.authorInitials,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
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
                              style: const TextStyle(fontSize: 12, color: HomePalette.textFaint),
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
    );
  }

  Widget _buildActions() {
    final likeCount = widget.initialLikeCount + (_liked ? 1 : 0);
    return Row(
      children: [
        _ActionButton(
          icon: _liked ? Icons.favorite : Icons.favorite_border,
          color: _liked ? HomePalette.red : HomePalette.textMuted,
          label: '$likeCount',
          onTap: () => setState(() => _liked = !_liked),
        ),
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          color: HomePalette.textMuted,
          label: '${widget.commentCount}',
          onTap: () {},
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
          onTap: () => setState(() => _saved = !_saved),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color, this.label, this.onTap});

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
                Text(label!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
