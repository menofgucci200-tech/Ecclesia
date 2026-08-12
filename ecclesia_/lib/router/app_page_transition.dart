import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The app's single page-transition style — a soft fade + upward slide,
/// used for every route so navigating the app feels like one continuous
/// experience instead of the default abrupt platform push.
CustomTransitionPage<void> fadeSlidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, .035), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}
