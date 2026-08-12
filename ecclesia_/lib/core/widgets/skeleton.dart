import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// A pulsing placeholder box — the building block for skeleton loading
/// states. Compose a few of these to sketch the shape of the real content
/// while it loads, instead of a bare centered spinner.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 6});

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// A ready-made skeleton row shaped like the app's most common list-item —
/// a leading avatar box + two lines of text (parishes, movements, feed
/// posts).
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 44, height: 44, radius: AppDimens.radiusMd),
          SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 140, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A vertical list of [count] [SkeletonListTile]s — the full-list loading
/// state for any screen that shows a list of cards.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimens.md),
      itemBuilder: (_, _) => const SkeletonListTile(),
    );
  }
}

/// A stack of pulsing lines mimicking a paragraph of text — for long-form
/// content like liturgy readings.
class SkeletonParagraph extends StatelessWidget {
  const SkeletonParagraph({super.key, this.lines = 4});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines; i++) ...[
          SkeletonBox(width: i == lines - 1 ? 160 : double.infinity, height: 12),
          if (i != lines - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// A card shaped like the app's image-header content cards (parish feed
/// posts, campaigns) — an image block followed by a title and two body
/// lines.
class SkeletonFeedCard extends StatelessWidget {
  const SkeletonFeedCard({super.key, this.imageHeight = 148});

  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: double.infinity, height: imageHeight, radius: 0),
          const Padding(
            padding: EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 14),
                SizedBox(height: 10),
                SkeletonBox(width: double.infinity, height: 11),
                SizedBox(height: 6),
                SkeletonBox(width: 220, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
