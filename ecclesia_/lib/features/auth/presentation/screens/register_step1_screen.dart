import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_step_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../router/app_routes.dart';
import '../../domain/entities/gender.dart';
import '../providers/registration_draft_controller.dart';

/// Registration wizard — step 1: identity (first name, last name, gender).
class RegisterStep1Screen extends ConsumerStatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  ConsumerState<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends ConsumerState<RegisterStep1Screen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  Gender? _gender;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(registrationDraftProvider);
    _firstNameController = TextEditingController(text: draft.firstName);
    _lastNameController = TextEditingController(text: draft.lastName);
    _gender = draft.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _firstNameController.text.trim().length >= AppConstants.minNameLength &&
      _lastNameController.text.trim().length >= AppConstants.minNameLength &&
      _gender != null;

  void _submit() {
    if (!_isValid) return;

    ref.read(registrationDraftProvider.notifier).setPersonalInfo(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          gender: _gender!,
        );

    context.push(AppRoutes.registerStep2);
  }

  @override
  Widget build(BuildContext context) {
    return AuthStepScaffold(
      title: 'Informations du fidèle',
      subtitle: 'Entrez vos informations pour créer votre compte.',
      currentStep: 1,
      totalSteps: 3,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'PRÉNOM',
            controller: _firstNameController,
            hintText: 'Votre prénom',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimens.lg),
          AppTextField(
            label: 'NOM',
            controller: _lastNameController,
            hintText: 'Votre nom',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimens.lg),
          Text('GENRE', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              Expanded(
                child: _GenderOption(
                  label: 'Homme',
                  icon: Icons.male,
                  selected: _gender == Gender.male,
                  onTap: () => setState(() => _gender = Gender.male),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: _GenderOption(
                  label: 'Femme',
                  icon: Icons.female,
                  selected: _gender == Gender.female,
                  onTap: () => setState(() => _gender = Gender.female),
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PrimaryButton(
        label: 'Continuer',
        isEnabled: _isValid,
        onPressed: _submit,
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: AppDimens.fieldHeight,
        decoration: BoxDecoration(
          color: selected ? AppColors.navy.withValues(alpha: 0.06) : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.border,
            width: selected ? 1.8 : 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.navy : AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimens.sm),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.navy : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
