import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../router/app_routes.dart';
import '../../data/models/parish_model.dart';
import '../providers/associate_parish_controller.dart';
import '../providers/parish_detail_provider.dart';

/// Screen 2 of the parish selection flow: confirm the chosen parish, then
/// perform the automatic association.
class ConfirmParishScreen extends ConsumerWidget {
  const ConfirmParishScreen({super.key, required this.parishId});

  final int parishId;

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(associateParishControllerProvider.notifier).associate(parishId);
      if (!context.mounted) return;
      context.go(AppRoutes.home);
    } on ApiException catch (error) {
      if (!context.mounted) return;
      AppSnackBar.showError(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(parishDetailProvider(parishId));
    final isAssociating = ref.watch(associateParishControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmez votre paroisse')),
      body: LoadingOverlay(
        isLoading: isAssociating,
        message: 'Association à votre paroisse...',
        child: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.navy)),
          error: (error, _) => _ErrorState(
            message: error is ApiException ? error.message : 'Une erreur est survenue.',
            onRetry: () => ref.invalidate(parishDetailProvider(parishId)),
          ),
          data: (parish) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimens.lg),
                        _ParishDetailCard(parish: parish),
                        const SizedBox(height: AppDimens.xl),
                        Text(
                          'Vous êtes sur le point d\'associer votre compte à cette paroisse. '
                          'Vous pourrez modifier ce choix ultérieurement depuis votre profil.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isAssociating ? null : () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                            ),
                            foregroundColor: AppColors.navy,
                          ),
                          child: const Text('Retour', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          label: 'Confirmer ma paroisse',
                          isLoading: isAssociating,
                          trailingIcon: Icons.check,
                          onPressed: () => _confirm(context, ref),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParishDetailCard extends StatelessWidget {
  const _ParishDetailCard({required this.parish});

  final ParishModel parish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
                child: const Icon(Icons.church_outlined, color: AppColors.white, size: 26),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Text(
                  parish.name,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppDimens.md),
          _DetailRow(icon: Icons.location_on_outlined, label: 'Adresse', value: parish.address),
          _DetailRow(icon: Icons.location_city_outlined, label: 'Ville', value: parish.city),
          _DetailRow(icon: Icons.map_outlined, label: 'Commune', value: parish.commune),
          _DetailRow(icon: Icons.public, label: 'Pays', value: parish.country),
          _DetailRow(icon: Icons.qr_code_2, label: 'Code paroisse', value: parish.code),
          _DetailRow(icon: Icons.phone_outlined, label: 'Téléphone', value: parish.phone),
          _DetailRow(icon: Icons.mail_outline, label: 'E-mail', value: parish.email),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  value!,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44, color: AppColors.error),
            const SizedBox(height: AppDimens.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppDimens.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
