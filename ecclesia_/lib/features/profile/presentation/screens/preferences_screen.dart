import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
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
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Que voir en priorité ?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navyDark)),
          const SizedBox(height: 4),
          const Text('Choisissez le contenu affiché en premier sur l\'accueil.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _PriorityTile(label: 'Contenu de ma paroisse', value: 'parish', groupValue: _priority, onTap: () => setState(() => _priority = 'parish')),
          const SizedBox(height: 8),
          _PriorityTile(label: 'Contenu de mes mouvements', value: 'movements', groupValue: _priority, onTap: () => setState(() => _priority = 'movements')),

          const SizedBox(height: 28),
          const Text('Sections de l\'accueil', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navyDark)),
          const SizedBox(height: 4),
          const Text('Activez ou masquez ce que vous voulez voir.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          ..._sections.map((s) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.navy,
                title: Text(s.$2),
                value: !_hidden.contains(s.$1),
                onChanged: (on) => setState(() => on ? _hidden.remove(s.$1) : _hidden.add(s.$1)),
              )),

          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy, padding: const EdgeInsets.symmetric(vertical: 15)),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy.withValues(alpha: .06) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.navy : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? AppColors.navy : AppColors.textHint, size: 22),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? AppColors.navy : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
