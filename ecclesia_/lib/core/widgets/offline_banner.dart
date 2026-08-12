import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/cache_service.dart';
import '../theme/app_colors.dart';

/// A slim banner shown whenever [isOfflineProvider] is true — i.e. the last
/// network attempt failed and the screen is showing the last cached data
/// instead of a blank error state.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: isOffline
          ? Container(
              width: double.infinity,
              color: AppColors.goldLight.withValues(alpha: .25),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 15, color: AppColors.navyDark),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hors ligne — dernières données synchronisées',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navyDark),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}
