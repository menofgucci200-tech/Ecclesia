import 'package:flutter/material.dart';

import '../network/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// The tone of a [MessageCard], which drives its colour and default icon.
enum MessageKind { error, warning, info, success }

/// A calm, reassuring inline feedback card used across the app to surface
/// errors and validation messages — a friendlier alternative to a bare
/// snackbar. It shows an icon, an optional bold title, the message, and an
/// optional action button (e.g. « Réessayer »).
class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.message,
    this.title,
    this.kind = MessageKind.error,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? title;
  final MessageKind kind;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Builds a card straight from an [ApiException], picking a gentle amber tone
  /// for connectivity / validation hiccups and a firmer red for real errors,
  /// and wiring a « Réessayer » button when retrying could help.
  factory MessageCard.fromException(
    ApiException error, {
    Key? key,
    VoidCallback? onRetry,
  }) {
    final bool soft = error.isConnectivity || error is ValidationException;
    final bool canRetry = onRetry != null && error.isRetryable;
    return MessageCard(
      key: key,
      kind: soft ? MessageKind.warning : MessageKind.error,
      icon: error is NetworkException
          ? Icons.wifi_off_rounded
          : error.isConnectivity
              ? Icons.cloud_off_rounded
              : null,
      title: error.title,
      message: error.message,
      actionLabel: canRetry ? 'Réessayer' : null,
      onAction: canRetry ? onRetry : null,
    );
  }

  Color get _accent => switch (kind) {
        MessageKind.error => AppColors.error,
        MessageKind.warning => AppColors.warning,
        MessageKind.info => AppColors.navy,
        MessageKind.success => AppColors.success,
      };

  IconData get _defaultIcon => switch (kind) {
        MessageKind.error => Icons.error_outline_rounded,
        MessageKind.warning => Icons.info_outline_rounded,
        MessageKind.info => Icons.info_outline_rounded,
        MessageKind.success => Icons.check_circle_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final bg = Color.alphaBlend(accent.withValues(alpha: 0.08), AppColors.white);
    final border = accent.withValues(alpha: 0.28);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon ?? _defaultIcon, color: accent, size: 22),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                        child: Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppDimens.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAction,
                icon: Icon(Icons.refresh_rounded, size: 18, color: accent),
                label: Text(
                  actionLabel!,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.md,
                    vertical: AppDimens.xs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
