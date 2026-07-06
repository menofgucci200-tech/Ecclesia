import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_step_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../router/app_routes.dart';
import '../providers/registration_draft_controller.dart';
import '../providers/reset_password_controller.dart';

/// Enters the e-mailed code and a new password, then signs the user in.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.emailHint});

  final String? emailHint;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _codeController.text.trim().length == 6 &&
      _passwordController.text.length >= AppConstants.minPasswordLength &&
      _passwordController.text == _confirmController.text;

  Future<void> _submit(String phone) async {
    if (!_isValid) return;

    try {
      await ref.read(resetPasswordControllerProvider.notifier).reset(
            phone: phone,
            code: _codeController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmController.text,
          );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Mot de passe réinitialisé.');
      context.go(AppRoutes.home);
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(registrationDraftProvider).phone;
    final isLoading = ref.watch(resetPasswordControllerProvider).isLoading;

    return AuthStepScaffold(
      title: 'Réinitialisation',
      subtitle: widget.emailHint != null && widget.emailHint!.isNotEmpty
          ? 'Entrez le code envoyé à ${widget.emailHint} et choisissez un nouveau mot de passe.'
          : 'Entrez le code reçu par e-mail et choisissez un nouveau mot de passe.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'CODE DE VÉRIFICATION',
            controller: _codeController,
            hintText: '6 chiffres',
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimens.lg),
          AppTextField(
            label: 'NOUVEAU MOT DE PASSE',
            controller: _passwordController,
            obscureText: _obscure,
            prefixIcon: Icons.lock_outline,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          AppTextField(
            label: 'CONFIRMER LE MOT DE PASSE',
            controller: _confirmController,
            obscureText: _obscure,
            prefixIcon: Icons.lock_outline,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(phone),
          ),
          if (_confirmController.text.isNotEmpty &&
              _confirmController.text != _passwordController.text) ...[
            const SizedBox(height: AppDimens.sm),
            const Text(
              'Les mots de passe ne correspondent pas.',
              style: TextStyle(color: AppColors.error, fontSize: 12.5),
            ),
          ],
        ],
      ),
      bottom: PrimaryButton(
        label: 'Réinitialiser',
        isLoading: isLoading,
        isEnabled: _isValid,
        onPressed: () => _submit(phone),
      ),
    );
  }
}
