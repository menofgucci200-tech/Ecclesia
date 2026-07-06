import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/auth_step_scaffold.dart';
import '../../../../core/widgets/phone_number_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../router/app_routes.dart';
import '../providers/phone_check_controller.dart';

/// Step 2 of the entry sequence: the faithful enters their phone number.
/// Depending on whether an account already exists, we route to Login or to
/// the registration intro.
class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final valid = Validators.phone(value) == null;
    if (valid != _isValid) {
      setState(() => _isValid = valid);
    }
  }

  Future<void> _submit() async {
    if (!_isValid) return;

    try {
      final exists = await ref
          .read(phoneCheckControllerProvider.notifier)
          .check(_phoneController.text);

      if (!mounted) return;

      context.push(exists ? AppRoutes.login : AppRoutes.registerIntro);
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(phoneCheckControllerProvider).isLoading;

    return AuthStepScaffold(
      title: 'Numéro de téléphone',
      subtitle: 'Veuillez saisir votre numéro de téléphone pour continuer.',
      currentStep: 2,
      totalSteps: 3,
      body: PhoneNumberField(
        controller: _phoneController,
        autofocus: true,
        onChanged: _onChanged,
        onSubmitted: (_) => _submit(),
      ),
      bottom: PrimaryButton(
        label: 'Vérifier',
        isLoading: isLoading,
        isEnabled: _isValid,
        onPressed: _submit,
      ),
    );
  }
}
