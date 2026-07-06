import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../router/app_routes.dart';
import '../../../auth/presentation/providers/session_controller.dart';

/// The authenticated landing screen: confirms the faithful's identity and
/// parish membership, and opens the profile space.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecclesia'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
            tooltip: 'Mon profil',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue, ${user?.firstName ?? ''} !',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppDimens.sm),
              const Text(
                'Votre compte est actif et connecté à votre paroisse.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimens.xxl),
              if (user?.parish != null) _ParishCard(name: user!.parish!.name, address: user.parish!.address),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParishCard extends StatelessWidget {
  const _ParishCard({required this.name, this.address});

  final String name;
  final String? address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        children: [
          const Icon(Icons.church_outlined, color: AppColors.navy, size: 28),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (address != null) ...[
                  const SizedBox(height: 2),
                  Text(address!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
