import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/auth_step_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../router/app_routes.dart';

/// Step 3 of the entry sequence: shown when the phone number has no account
/// yet — invites the faithful to create their profile.
class RegistrationIntroScreen extends StatelessWidget {
  const RegistrationIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthStepScaffold(
      title: 'Il ne reste plus qu\'une\ndernière étape…',
      subtitle: 'Cher fidèle, cliquez pour créer votre profil.',
      currentStep: 3,
      totalSteps: 3,
      body: Center(
        child: Icon(
          Icons.edit_document,
          size: 96,
          color: AppColors.navy.withValues(alpha: 0.85),
        ),
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Nouveau sur Ecclesia ?', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppDimens.xs),
                Text(
                  'L\'inscription est rapide et sécurisée.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          PrimaryButton(
            label: 'Créer mon compte',
            onPressed: () => context.push(AppRoutes.registerStep1),
          ),
        ],
      ),
    );
  }
}
