import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import 'session_controller.dart';

/// Verifies the reset code, sets a new password and opens the session.
class ResetPasswordController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> reset({
    required String phone,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(authRepositoryProvider).resetPassword(
            phone: phone,
            code: code,
            password: password,
            passwordConfirmation: passwordConfirmation,
          );
      await ref.read(sessionControllerProvider.notifier).onAuthenticated(result);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final resetPasswordControllerProvider =
    AsyncNotifierProvider<ResetPasswordController, void>(
  ResetPasswordController.new,
);
