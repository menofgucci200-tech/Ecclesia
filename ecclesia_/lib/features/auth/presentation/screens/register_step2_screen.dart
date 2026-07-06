import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/phone_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_step_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../router/app_routes.dart';
import '../providers/registration_draft_controller.dart';

/// Registration wizard — step 2: contact details (verified phone + optional
/// email).
class RegisterStep2Screen extends ConsumerStatefulWidget {
  const RegisterStep2Screen({super.key});

  @override
  ConsumerState<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends ConsumerState<RegisterStep2Screen> {
  late final TextEditingController _emailController;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: ref.read(registrationDraftProvider).email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _isValid => Validators.email(_emailController.text) == null;

  void _submit() {
    setState(() => _emailError = Validators.email(_emailController.text));
    if (_emailError != null) {
      return;
    }

    final email = _emailController.text.trim();
    ref.read(registrationDraftProvider.notifier).setEmail(email.isEmpty ? null : email);

    context.push(AppRoutes.registerStep3);
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(registrationDraftProvider).phone;

    return AuthStepScaffold(
      title: 'Coordonnées',
      subtitle: 'Comment pouvons-nous vous contacter ?',
      currentStep: 2,
      totalSteps: 3,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NUMÉRO DE TÉLÉPHONE', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppDimens.sm),
          Container(
            height: AppDimens.fieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Text(
                  'CI',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                Text(
                  AppConstants.defaultDialCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Container(height: 24, width: 1.2, color: AppColors.borderStrong),
                const SizedBox(width: AppDimens.md),
                const Icon(Icons.phone_outlined, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppDimens.sm),
                Text(
                  PhoneHelper.formatNational(phone),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          const Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: AppColors.success),
              SizedBox(width: 6),
              Text(
                'Numéro vérifié',
                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.xl),
          AppTextField(
            label: 'ADRESSE E-MAIL',
            labelTrailing: const _OptionalBadge(),
            controller: _emailController,
            hintText: 'nom@email.com (facultatif)',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: (_) => _emailError,
            onChanged: (_) => setState(() => _emailError = null),
            onSubmitted: (_) => _submit(),
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

class _OptionalBadge extends StatelessWidget {
  const _OptionalBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: const Text(
        'Facultatif',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }
}
