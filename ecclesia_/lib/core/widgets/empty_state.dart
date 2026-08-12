import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// A centered icon + message shown when a list/section has nothing to show.
/// Replaces the several near-identical "empty" widgets that used to be
/// redefined per screen (parish list, home feed, movements, agenda...).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppColors.textFaint),
          const SizedBox(height: AppDimens.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
          ),
          if (action != null) ...[const SizedBox(height: AppDimens.md), action!],
        ],
      ),
    );
  }
}
