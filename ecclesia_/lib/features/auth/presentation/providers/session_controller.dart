import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_events.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/models/auth_result_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// Owns the authenticated session for the whole app.
///
/// On start it performs the auto-login: read the stored token and resolve the
/// current user via `/auth/me`. A `null` value means "unauthenticated".
class SessionController extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    // React to a rejected token (emitted by the network layer on 401).
    ref.listen(unauthorizedEventProvider, (previous, next) {
      if (previous != next) {
        _handleExpiry();
      }
    });

    final storage = ref.read(secureStorageServiceProvider);
    final token = await storage.readToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return await ref.read(authRepositoryProvider).fetchMe();
    } on UnauthorizedException {
      await storage.deleteToken();
      return null;
    } on ApiException {
      // Server unreachable — stay logged out for now, keep the token so the
      // next launch can retry the auto-login.
      return null;
    }
  }

  /// Persist the token and mark the session as authenticated.
  Future<void> onAuthenticated(AuthResultModel result) async {
    await ref.read(secureStorageServiceProvider).writeToken(result.token);
    state = AsyncData(result.user);
  }

  /// Update the cached user (e.g. after joining a parish).
  void updateUser(UserModel user) {
    state = AsyncData(user);
  }

  /// Re-fetch the current user from the API (e.g. after associating a parish).
  Future<void> refreshUser() async {
    try {
      final user = await ref.read(authRepositoryProvider).fetchMe();
      state = AsyncData(user);
    } on ApiException {
      // Keep the current state on a transient failure.
    }
  }

  /// Revoke the token server-side (best effort) and clear the local session.
  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } on ApiException {
      // Ignore — we clear the local session regardless.
    }
    await ref.read(secureStorageServiceProvider).deleteToken();
    state = const AsyncData(null);
  }

  void _handleExpiry() {
    if (state.value != null) {
      state = const AsyncData(null);
    }
  }
}

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, UserModel?>(SessionController.new);

/// Convenience selectors for the router and UI.
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(sessionControllerProvider).value;
});
