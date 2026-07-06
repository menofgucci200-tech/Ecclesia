import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import 'registration_draft_controller.dart';

/// Drives the "check-phone" step: verifies whether an account already exists
/// for the entered number, and records it in the registration draft either way
/// (it is needed again in the registration "Coordonnées" step).
class PhoneCheckController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Returns `true` if an account already exists for [phone].
  Future<bool> check(String phone) async {
    state = const AsyncLoading();
    try {
      final exists = await ref.read(authRepositoryProvider).checkPhone(phone);
      ref.read(registrationDraftProvider.notifier).setPhone(phone);
      state = const AsyncData(null);
      return exists;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final phoneCheckControllerProvider =
    AsyncNotifierProvider<PhoneCheckController, void>(PhoneCheckController.new);
