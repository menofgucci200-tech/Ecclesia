import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/providers/session_controller.dart';

/// Bridges Riverpod's [sessionControllerProvider] changes to GoRouter's
/// `refreshListenable`, so the redirect logic re-evaluates whenever the
/// authenticated session changes (login, logout, token expiry).
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(sessionControllerProvider, (previous, next) {
      notifyListeners();
    });
  }
}
