import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

enum PrimaryButtonVariant { navy, gold }

/// The app's primary call-to-action button, with a built-in loading state and
/// an optional trailing icon (the arrow used across the onboarding flow).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.trailingIcon = Icons.arrow_forward,
    this.variant = PrimaryButtonVariant.navy,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? trailingIcon;
  final PrimaryButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final bool interactive = isEnabled && !isLoading && onPressed != null;
    final Color background =
        variant == PrimaryButtonVariant.gold ? AppColors.gold : AppColors.navy;

    return ElevatedButton(
      onPressed: interactive ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: background.withValues(alpha: 0.5),
        disabledForegroundColor: AppColors.white,
        minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppDimens.sm),
                  Icon(trailingIcon, size: 20),
                ],
              ],
            ),
    );
  }
}
