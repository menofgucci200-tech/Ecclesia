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
import '../providers/change_password_controller.dart';

/// Lets an authenticated faithful change their password from the profile space.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _currentController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _currentController.text.isNotEmpty &&
      _passwordController.text.length >= AppConstants.minPasswordLength &&
      _passwordController.text == _confirmController.text &&
      _passwordController.text != _currentController.text;

  Future<void> _submit() async {
    if (!_isValid) return;

    try {
      await ref.read(changePasswordControllerProvider.notifier).change(
            currentPassword: _currentController.text,
            password: _passwordController.text,
            passwordConfirmation: _confirmController.text,
          );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Mot de passe mis à jour.');
      context.pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(changePasswordControllerProvider).isLoading;

    return AuthStepScaffold(
      showHelp: false,
      title: 'Changer le mot de passe',
      subtitle: 'Saisissez votre mot de passe actuel puis le nouveau.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'MOT DE PASSE ACTUEL',
            controller: _currentController,
            obscureText: _obscure,
            prefixIcon: Icons.lock_outline,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimens.lg),
          AppTextField(
            label: 'NOUVEAU MOT DE PASSE',
            controller: _passwordController,
            obscureText: _obscure,
            prefixIcon: Icons.lock_reset,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          AppTextField(
            label: 'CONFIRMER LE NOUVEAU MOT DE PASSE',
            controller: _confirmController,
            obscureText: _obscure,
            prefixIcon: Icons.lock_reset,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
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
        label: 'Mettre à jour',
        isLoading: isLoading,
        isEnabled: _isValid,
        trailingIcon: null,
        onPressed: _submit,
      ),
    );
  }
}
