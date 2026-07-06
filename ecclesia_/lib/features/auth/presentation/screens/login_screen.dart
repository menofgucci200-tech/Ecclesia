import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/phone_helper.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_step_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../router/app_routes.dart';
import '../providers/login_controller.dart';
import '../providers/registration_draft_controller.dart';

/// Authenticates a faithful whose phone number already has an account.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isValid => _passwordController.text.isNotEmpty;

  Future<void> _submit(String phone) async {
    if (!_isValid) return;

    try {
      await ref.read(loginControllerProvider.notifier).login(
            phone: phone,
            password: _passwordController.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.welcomeUser);
    } on UnauthorizedException {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Mot de passe incorrect.');
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(context, error.message);
    }
  }

  void _forgotPassword() {
    context.push(AppRoutes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(registrationDraftProvider).phone;
    final isLoading = ref.watch(loginControllerProvider).isLoading;

    return AuthStepScaffold(
      title: 'Bon retour parmi nous',
      subtitle: 'Entrez votre mot de passe pour continuer.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhoneSummary(phone: phone),
          const SizedBox(height: AppDimens.xl),
          AppTextField(
            label: 'MOT DE PASSE',
            controller: _passwordController,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(phone),
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              child: const Text('Mot de passe oublié ?'),
            ),
          ),
        ],
      ),
      bottom: PrimaryButton(
        label: 'Se connecter',
        isLoading: isLoading,
        isEnabled: _isValid,
        onPressed: () => _submit(phone),
      ),
    );
  }
}

class _PhoneSummary extends StatelessWidget {
  const _PhoneSummary({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
