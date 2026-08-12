import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../data/profile_remote_data_source.dart';

/// Lets the faithful personalise what they see first and which home sections
/// are shown.
class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  // (key, label) for the toggleable home sections.
  static const _sections = [
    ('liturgy', 'Liturgie du jour'),
    ('feed', 'Fil paroissial'),
    ('events', 'Événements à venir'),
    ('activities', 'Mes activités'),
    ('collection', 'Dons & collectes'),
    ('quote', 'Citation du jour'),
  ];

  late String _priority;
  late Set<String> _hidden;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(currentUserProvider);
    _priority = u?.feedPriority ?? 'parish';
    _hidden = {...(u?.hiddenSections ?? const [])};
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(profileDataSourceProvider).updatePreferences({
        'feed_priority': _priority,
        'hidden_sections': _hidden.toList(),
      });
      await ref.read(sessionControllerProvider.notifier).refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Préférences enregistrées'), behavior: SnackBarBehavior.floating));
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personnaliser l\'application')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        children: [
          const Text('Que voir en priorité ?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navyDark)),
          const SizedBox(height: 4),
          const Text('Choisissez le contenu affiché en premier sur l\'accueil.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppDimens.md),
          _PriorityTile(label: 'Contenu de ma paroisse', value: 'parish', groupValue: _priority, onTap: () => setState(() => _priority = 'parish')),
          const SizedBox(height: AppDimens.sm),
          _PriorityTile(label: 'Contenu de mes mouvements', value: 'movements', groupValue: _priority, onTap: () => setState(() => _priority = 'movements')),

          const SizedBox(height: AppDimens.xxl),
          const Text('Sections de l\'accueil', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navyDark)),
          const SizedBox(height: 4),
          const Text('Activez ou masquez ce que vous voulez voir.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppDimens.sm),
          AppCard(
            color: AppColors.surfaceMuted,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
            child: Column(
              children: [
                for (var i = 0; i < _sections.length; i++)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.navy,
                    title: Text(_sections[i].$2),
                    value: !_hidden.contains(_sections[i].$1),
                    onChanged: (on) => setState(() => on ? _hidden.remove(_sections[i].$1) : _hidden.add(_sections[i].$1)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.xl),
          PrimaryButton(label: 'Enregistrer', onPressed: _save, isLoading: _saving, trailingIcon: null),
        ],
      ),
    );
  }
}

class _PriorityTile extends StatelessWidget {
  const _PriorityTile({required this.label, required this.value, required this.groupValue, required this.onTap});
  final String label;
  final String value;
  final String groupValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return AppCard(
      onTap: onTap,
      color: selected ? AppColors.navy.withValues(alpha: .06) : AppColors.surfaceMuted,
      borderColor: selected ? AppColors.navy : Colors.transparent,
      radius: AppDimens.radiusMd,
      child: Row(
        children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? AppColors.navy : AppColors.textHint, size: 22),
          const SizedBox(width: AppDimens.md),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? AppColors.navy : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
