import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'help_button.dart';
import 'step_progress_bar.dart';
import 'support_contact_sheet.dart';

/// Shared layout for every screen of the authentication / registration flow:
/// a back button and help pill, an optional step indicator, a title/subtitle,
/// a scrollable body and a pinned bottom action that stays above the keyboard.
class AuthStepScaffold extends StatelessWidget {
  const AuthStepScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.bottom,
    this.subtitle,
    this.currentStep,
    this.totalSteps,
    this.showBack = true,
    this.showHelp = true,
    this.onBack,
    this.onHelp,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget bottom;
  final int? currentStep;
  final int? totalSteps;
  final bool showBack;
  final bool showHelp;
  final VoidCallback? onBack;
  final VoidCallback? onHelp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showProgress = currentStep != null && totalSteps != null;
    // A custom onBack always takes priority; otherwise only show the arrow
    // when there is actually somewhere to go back to, so it never appears
    // unresponsive.
    final bool canGoBack = showBack && (onBack != null || context.canPop());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimens.sm),
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    if (canGoBack)
                      IconButton(
                        onPressed: onBack ?? () => context.pop(),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 22,
                          color: AppColors.navyDark,
                        ),
                      ),
                    const Spacer(),
                    if (showHelp)
                      HelpButton(
                        onPressed: onHelp ?? () => showSupportContactSheet(context),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.xl),
              if (showProgress) ...[
                StepProgressBar(
                  totalSteps: totalSteps!,
                  currentStep: currentStep!,
                ),
                const SizedBox(height: AppDimens.xl),
              ],
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.displaySmall),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppDimens.md),
                        Text(subtitle!, style: theme.textTheme.bodyMedium),
                      ],
                      const SizedBox(height: AppDimens.xxl),
                      body,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimens.md,
                  bottom: AppDimens.md,
                ),
                child: bottom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
