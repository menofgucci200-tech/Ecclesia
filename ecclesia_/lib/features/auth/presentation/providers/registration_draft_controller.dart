import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/gender.dart';
import '../../domain/entities/registration_draft.dart';

/// Holds the in-progress registration wizard state across its three screens.
/// Purely local/synchronous — no network call happens until the final step.
class RegistrationDraftController extends Notifier<RegistrationDraft> {
  @override
  RegistrationDraft build() => const RegistrationDraft();

  void setPhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void setPersonalInfo({
    required String firstName,
    required String lastName,
    required Gender gender,
  }) {
    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
      gender: gender,
    );
  }

  void setEmail(String? email) {
    state = state.copyWith(email: email);
  }

  void reset() {
    state = const RegistrationDraft();
  }
}

final registrationDraftProvider =
    NotifierProvider<RegistrationDraftController, RegistrationDraft>(
  RegistrationDraftController.new,
);
