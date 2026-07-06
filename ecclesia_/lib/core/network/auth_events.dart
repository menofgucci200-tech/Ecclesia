import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A tiny counter that the network layer increments whenever an authenticated
/// request is rejected with 401. Feature layers (the session controller) listen
/// to it to log the user out — keeping `core` free of any feature dependency.
class UnauthorizedEventNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void signal() => state = state + 1;
}

final unauthorizedEventProvider =
    NotifierProvider<UnauthorizedEventNotifier, int>(
  UnauthorizedEventNotifier.new,
);
