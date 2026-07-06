import 'package:flutter/material.dart';
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
import '../providers/register_controller.dart';
import '../widgets/password_strength_bar.dart';

/// Registration wizard — step 3 (final): password creation and submission.
/// The password is simple and free-form — the only requirement is that both
/// entries match.
class RegisterStep3Screen extends ConsumerStatefulWidget {
  const RegisterStep3Screen({super.key});

  @override
  ConsumerState<RegisterStep3Screen> createState() => _RegisterStep3ScreenState();
}

class _RegisterStep3ScreenState extends ConsumerState<RegisterStep3Screen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String get _password => _passwordController.text;
  String get _confirm => _confirmController.text;

  bool get _isValid =>
      _password.length >= AppConstants.minPasswordLength &&
      _password == _confirm;

  bool get _showMismatch =>
      _confirm.isNotEmpty && _password != _confirm;

  Future<void> _submit() async {
    if (!_isValid) return;

    try {
      await ref.read(registerControllerProvider.notifier).submit(
            password: _password,
            passwordConfirmation: _confirm,
          );
      if (!mounted) return;
      context.go(AppRoutes.welcomeUser);
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(registerControllerProvider).isLoading;

    return AuthStepScaffold(
      title: 'Dernière étape',
      subtitle: 'Créez un mot de passe sécurisé pour votre compte.',
      currentStep: 3,
      totalSteps: 3,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'MOT DE PASSE',
            controller: _passwordController,
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outline,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            suffix: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          PasswordStrengthBar(password: _password),
          const SizedBox(height: AppDimens.lg),
          AppTextField(
            label: 'CONFIRMER LE MOT DE PASSE',
            controller: _confirmController,
            obscureText: _obscureConfirm,
            prefixIcon: Icons.lock_outline,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
            suffix: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          if (_showMismatch) ...[
            const SizedBox(height: AppDimens.sm),
            const Text(
              'Les mots de passe ne correspondent pas.',
              style: TextStyle(color: AppColors.error, fontSize: 12.5),
            ),
          ],
        ],
      ),
      bottom: PrimaryButton(
        label: 'Créer mon compte',
        isLoading: isLoading,
        isEnabled: _isValid,
        onPressed: _submit,
      ),
    );
  }
}
