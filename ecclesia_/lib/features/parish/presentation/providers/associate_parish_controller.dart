import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/session_controller.dart';
import '../../data/models/parish_model.dart';
import '../../data/repositories/parish_repository_impl.dart';

/// Performs the automatic association of the faithful to the chosen parish,
/// then refreshes the session so the router lets them into the dashboard.
class AssociateParishController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<ParishModel> associate(int parishId) async {
    state = const AsyncLoading();
    try {
      final parish = await ref.read(parishRepositoryProvider).associate(parishId);
      await ref.read(sessionControllerProvider.notifier).refreshUser();
      state = const AsyncData(null);
      return parish;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final associateParishControllerProvider =
    AsyncNotifierProvider<AssociateParishController, void>(
  AssociateParishController.new,
);
