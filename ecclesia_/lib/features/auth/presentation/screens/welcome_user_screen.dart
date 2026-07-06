import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../router/app_routes.dart';
import '../providers/session_controller.dart';

/// Full-bleed welcome screen shown right after a successful login or
/// registration, personalized with the faithful's first name (design screen 7).
class WelcomeUserScreen extends ConsumerWidget {
  const WelcomeUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final firstName = user?.firstName ?? '';

    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.navy),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xE60F2647),
                  Color(0x800F2647),
                  Color(0xF20F2647),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimens.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 56,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.1,
                      ),
                      children: [
                        const TextSpan(text: 'Bienvenue, '),
                        TextSpan(
                          text: firstName,
                          style: const TextStyle(color: AppColors.gold),
                        ),
                        const TextSpan(text: ' !'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  Text(
                    'Votre communauté paroissiale est désormais à portée de main. '
                    'Recevez les actualités, les annonces, faîtes vos demandes de messe '
                    'et restez connecté à la vie de votre paroisse, où que vous soyez.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontSize: 15.5,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppDimens.xxl),
                  PrimaryButton(
                    label: 'Commencer',
                    variant: PrimaryButtonVariant.gold,
                    onPressed: () => context.go(
                      user?.hasParish == true
                          ? AppRoutes.home
                          : AppRoutes.chooseParish,
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
