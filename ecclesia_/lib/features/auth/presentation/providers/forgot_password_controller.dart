import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';

/// Requests a reset code by e-mail for a given phone number.
class ForgotPasswordController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Returns the masked destination e-mail on success.
  Future<String> sendCode(String phone) async {
    state = const AsyncLoading();
    try {
      final emailHint =
          await ref.read(authRepositoryProvider).forgotPassword(phone);
      state = const AsyncData(null);
      return emailHint;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final forgotPasswordControllerProvider =
    AsyncNotifierProvider<ForgotPasswordController, void>(
  ForgotPasswordController.new,
);
