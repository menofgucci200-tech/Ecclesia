import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../router/app_routes.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../../profile/presentation/screens/preferences_screen.dart';
import '../screens/liturgy_today_screen.dart';
import '../theme/home_palette.dart';

/// The right-side drawer opened from the bottom nav's "Menu" button. Hosts
/// what used to be the "Vie & Foi" grid plus the account actions that used
/// to live behind a dedicated "Profil" tab.
class HomeEndDrawer extends ConsumerWidget {
  const HomeEndDrawer({super.key});

  static const _lifeItems = [
    _DrawerItem('📖', 'Liturgie', _DrawerAction.liturgy),
    _DrawerItem('✝️', 'Évangile', _DrawerAction.liturgy),
    _DrawerItem('📚', 'Bible', _DrawerAction.soon),
    _DrawerItem('🙏', 'Prières', _DrawerAction.soon),
    _DrawerItem('📿', 'Chapelets', _DrawerAction.soon),
    _DrawerItem('👼', 'Saints', _DrawerAction.soon),
    _DrawerItem('❤️', 'Intentions', _DrawerAction.soon),
    _DrawerItem('🎓', 'Catéchèse', _DrawerAction.soon),
    _DrawerItem('🎧', 'Podcasts', _DrawerAction.soon),
    _DrawerItem('🎥', 'Enseignements', _DrawerAction.soon),
  ];

  void _soon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label — bientôt disponible'), behavior: SnackBarBehavior.floating));
  }

  void _openLiturgy(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LiturgyTodayScreen()));
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).pop();
    context.push(AppRoutes.profile);
  }

  void _openPreferences(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PreferencesScreen()));
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Se déconnecter', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(sessionControllerProvider.notifier).logout();
    if (context.mounted) context.go(AppRoutes.onboarding);
  }

  String _initials(String? first, String? last) {
    final a = (first != null && first.isNotEmpty) ? first[0] : '';
    final b = (last != null && last.isNotEmpty) ? last[0] : '';
    final initials = (a + b).toUpperCase();
    return initials.isEmpty ? '?' : initials;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Drawer(
      width: 300,
      backgroundColor: HomePalette.screenBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => _openProfile(context),
              child: Container(
                color: HomePalette.navy,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withValues(alpha: .15),
                      backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                      child: user?.avatarUrl == null
                          ? Text(
                              _initials(user?.firstName, user?.lastName),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Mon profil',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                          ),
                          if (user?.parish?.name != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              user!.parish!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withValues(alpha: .75), fontSize: 12.5),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: .75)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  const _SectionLabel('VIE & FOI'),
                  for (final item in _lifeItems)
                    _DrawerTile(
                      emoji: item.emoji,
                      label: item.label,
                      onTap: () => item.action == _DrawerAction.liturgy ? _openLiturgy(context) : _soon(context, item.label),
                    ),
                  const Divider(height: 24, color: HomePalette.cardBorder),
                  const _SectionLabel('COMPTE'),
                  _DrawerTile(icon: Icons.person_outline, label: 'Profil', onTap: () => _openProfile(context)),
                  _DrawerTile(icon: Icons.tune, label: 'Paramètres', onTap: () => _openPreferences(context)),
                  _DrawerTile(
                    icon: Icons.logout,
                    label: 'Se déconnecter',
                    danger: true,
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _DrawerAction { liturgy, soon }

class _DrawerItem {
  const _DrawerItem(this.emoji, this.label, this.action);
  final String emoji;
  final String label;
  final _DrawerAction action;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: HomePalette.textMuted, letterSpacing: .5),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({this.emoji, this.icon, required this.label, required this.onTap, this.danger = false});

  final String? emoji;
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : HomePalette.navy;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: emoji != null
                  ? Text(emoji!, style: const TextStyle(fontSize: 17))
                  : Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
