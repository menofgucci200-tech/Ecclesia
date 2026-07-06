import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/phone_helper.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/auth_step_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../router/app_routes.dart';
import '../providers/forgot_password_controller.dart';
import '../providers/registration_draft_controller.dart';

/// Requests a password reset code, sent by e-mail to the account owner.
class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  Future<void> _send(BuildContext context, WidgetRef ref, String phone) async {
    try {
      final emailHint =
          await ref.read(forgotPasswordControllerProvider.notifier).sendCode(phone);
      if (!context.mounted) return;
      context.push(AppRoutes.resetPassword, extra: emailHint);
    } on ApiException catch (error) {
      if (!context.mounted) return;
      AppSnackBar.showError(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phone = ref.watch(registrationDraftProvider).phone;
    final isLoading = ref.watch(forgotPasswordControllerProvider).isLoading;

    return AuthStepScaffold(
      title: 'Mot de passe oublié',
      subtitle:
          'Nous enverrons un code de réinitialisation à l\'adresse e-mail associée à votre compte.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.lg,
              vertical: AppDimens.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_iphone, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppDimens.sm),
                Text(
                  PhoneHelper.toE164(phone),
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.mail_outline, size: 18, color: AppColors.navy),
              SizedBox(width: AppDimens.sm),
              Expanded(
                child: Text(
                  'Vérifiez votre boîte de réception après l\'envoi. Le code expire au bout de 10 minutes.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PrimaryButton(
        label: 'Envoyer le code',
        isLoading: isLoading,
        onPressed: () => _send(context, ref, phone),
      ),
    );
  }
}
