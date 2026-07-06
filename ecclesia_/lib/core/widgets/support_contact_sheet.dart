import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Shows the temporary support contact number in a bottom sheet, with a
/// one-tap copy action.
Future<void> showSupportContactSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
    ),
    builder: (context) => const _SupportContactSheet(),
  );
}

class _SupportContactSheet extends StatelessWidget {
  const _SupportContactSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: const BoxDecoration(
                color: AppColors.helpBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent, color: AppColors.navy, size: 28),
            ),
            const SizedBox(height: AppDimens.lg),
            const Text(
              'Besoin d\'aide ?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppDimens.sm),
            const Text(
              'Notre équipe est disponible pour vous accompagner.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: AppDimens.xl),
            Material(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                onTap: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: AppConstants.supportPhone),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Numéro copié.')),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.lg,
                    vertical: AppDimens.lg,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone_outlined, color: AppColors.navy, size: 20),
                      SizedBox(width: AppDimens.md),
                      Text(
                        AppConstants.supportPhoneFormatted,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.copy_outlined, color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.md),
          ],
        ),
      ),
    );
  }
}
