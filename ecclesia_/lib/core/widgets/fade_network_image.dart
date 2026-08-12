import 'package:flutter/material.dart';

/// A network image that fades in once decoded instead of popping in, with a
/// soft placeholder shimmer while it loads and a graceful fallback when the
/// URL is missing or fails — used anywhere a card shows a real photo (parish
/// feed, campaigns) instead of a plain gradient.
class FadeNetworkImage extends StatelessWidget {
  const FadeNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  final String? url;
  final BoxFit fit;

  /// Shown when [url] is null/empty or fails to load.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return fallback ?? const SizedBox.shrink();

    return Image.network(
      url!,
      fit: fit,
      errorBuilder: (_, _, _) => fallback ?? const SizedBox.shrink(),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}
