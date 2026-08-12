import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// The app's single reusable card surface: a rounded, bordered panel,
/// optionally tappable with a ripple, a light scale-down press feedback and
/// a haptic tick. Use this instead of hand-rolling a `Container` +
/// `BoxDecoration` per screen.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimens.lg),
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.radius = AppDimens.radiusLg,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
    );

    if (onTap == null) {
      return Container(padding: padding, decoration: decoration, child: child);
    }

    return _PressableCard(
      onTap: onTap!,
      radius: radius,
      decoration: decoration,
      padding: padding,
      child: child,
    );
  }
}

class _PressableCard extends StatefulWidget {
  const _PressableCard({
    required this.onTap,
    required this.radius,
    required this.decoration,
    required this.padding,
    required this.child,
  });

  final VoidCallback onTap;
  final double radius;
  final BoxDecoration decoration;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          onHighlightChanged: (highlighted) => setState(() => _pressed = highlighted),
          borderRadius: BorderRadius.circular(widget.radius),
          child: Ink(
            decoration: widget.decoration,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
