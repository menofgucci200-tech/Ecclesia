import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// The "Besoin d'aide ?" pill shown in the top-right of the auth flow.
class HelpButton extends StatelessWidget {
  const HelpButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.helpBackground,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.support_agent, size: 20, color: AppColors.navy),
              SizedBox(width: AppDimens.sm),
              Text(
                'Besoin d\'aide ?',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
