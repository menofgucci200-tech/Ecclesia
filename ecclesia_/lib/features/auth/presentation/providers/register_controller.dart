import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/register_params.dart';
import 'registration_draft_controller.dart';
import 'session_controller.dart';

/// Drives the final registration step: submits the accumulated wizard draft
/// together with the chosen password, then opens the session.
class RegisterController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit({
    required String password,
    required String passwordConfirmation,
  }) async {
    final draft = ref.read(registrationDraftProvider);

    final params = RegisterParams(
      firstName: draft.firstName,
      lastName: draft.lastName,
      gender: draft.gender!,
      phone: draft.phone,
      email: draft.email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    state = const AsyncLoading();
    try {
      final result = await ref.read(authRepositoryProvider).register(params);
      await ref.read(sessionControllerProvider.notifier).onAuthenticated(result);
      ref.read(registrationDraftProvider.notifier).reset();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final registerControllerProvider =
    AsyncNotifierProvider<RegisterController, void>(RegisterController.new);
