import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../router/app_routes.dart';
import '../../../auth/presentation/providers/session_controller.dart';

/// The faithful's profile space: identity, parish and account actions.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(sessionControllerProvider.notifier).logout();
    if (context.mounted) {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.navy,
                  child: Text(
                    _initials(user?.firstName, user?.lastName),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                Text(user?.fullName ?? '', style: theme.textTheme.titleLarge),
                if (user?.phone != null)
                  Text(user!.phone, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.xl),
          if (user?.email != null)
            _InfoTile(icon: Icons.mail_outline, label: 'E-mail', value: user!.email!),
          const SizedBox(height: AppDimens.sm),
          Text('MA PAROISSE', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppDimens.sm),
          _ParishSection(
            name: user?.parish?.name,
            location: user?.parish?.locationLine,
            onChange: () => context.push(AppRoutes.chooseParish),
          ),
          const SizedBox(height: AppDimens.lg),
          _ActionTile(
            icon: Icons.lock_reset,
            label: 'Changer mon mot de passe',
            onTap: () => context.push(AppRoutes.changePassword),
          ),
          _ActionTile(
            icon: Icons.logout,
            label: 'Se déconnecter',
            danger: true,
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }

  String _initials(String? first, String? last) {
    final a = (first != null && first.isNotEmpty) ? first[0] : '';
    final b = (last != null && last.isNotEmpty) ? last[0] : '';
    final initials = (a + b).toUpperCase();
    return initials.isEmpty ? '?' : initials;
  }
}

class _ParishSection extends StatelessWidget {
  const _ParishSection({
    required this.name,
    required this.location,
    required this.onChange,
  });

  final String? name;
  final String? location;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
                child: const Icon(Icons.church_outlined, color: AppColors.white, size: 22),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? 'Aucune paroisse',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    if (location != null && location!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        location!,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onChange,
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Changer de paroisse'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.navy),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.navy, size: 22),
          const SizedBox(width: AppDimens.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.navy;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.w600, color: color),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
