import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: EcclesiaApp()));
}

class EcclesiaApp extends ConsumerWidget {
  const EcclesiaApp({super.key});

  /// Global text-size factor applied on top of the user's system setting,
  /// to keep the interface compact across every screen.
  static const double _textScaleFactor = 0.88;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final systemFactor = mediaQuery.textScaler.scale(1);
        final scaled = (systemFactor * _textScaleFactor).clamp(0.7, 1.2);

        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(scaled)),
          child: child!,
        );
      },
    );
  }
}
