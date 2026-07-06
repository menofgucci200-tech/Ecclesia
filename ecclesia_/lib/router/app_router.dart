import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/session_controller.dart';
import '../features/auth/presentation/screens/change_password_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/phone_entry_screen.dart';
import '../features/auth/presentation/screens/register_step1_screen.dart';
import '../features/auth/presentation/screens/register_step2_screen.dart';
import '../features/auth/presentation/screens/register_step3_screen.dart';
import '../features/auth/presentation/screens/registration_intro_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/welcome_user_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/parish/presentation/screens/choose_parish_screen.dart';
import '../features/parish/presentation/screens/confirm_parish_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import 'app_routes.dart';
import 'router_refresh_notifier.dart';
import 'splash_screen.dart';

/// Routes reachable while there is no authenticated session.
const _publicOnlyRoutes = {
  AppRoutes.onboarding,
  AppRoutes.phone,
  AppRoutes.login,
  AppRoutes.forgotPassword,
  AppRoutes.resetPassword,
  AppRoutes.registerIntro,
  AppRoutes.registerStep1,
  AppRoutes.registerStep2,
  AppRoutes.registerStep3,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.phone, builder: (_, _) => const PhoneEntryScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) =>
            ResetPasswordScreen(emailHint: state.extra as String?),
      ),
      GoRoute(
        path: AppRoutes.registerIntro,
        builder: (_, _) => const RegistrationIntroScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerStep1,
        builder: (_, _) => const RegisterStep1Screen(),
      ),
      GoRoute(
        path: AppRoutes.registerStep2,
        builder: (_, _) => const RegisterStep2Screen(),
      ),
      GoRoute(
        path: AppRoutes.registerStep3,
        builder: (_, _) => const RegisterStep3Screen(),
      ),
      GoRoute(path: AppRoutes.welcomeUser, builder: (_, _) => const WelcomeUserScreen()),
      GoRoute(path: AppRoutes.chooseParish, builder: (_, _) => const ChooseParishScreen()),
      GoRoute(
        path: AppRoutes.confirmParish,
        builder: (context, state) => ConfirmParishScreen(parishId: state.extra as int),
      ),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(path: AppRoutes.profile, builder: (_, _) => const ProfileScreen()),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (_, _) => const ChangePasswordScreen(),
      ),
    ],
  );
});

/// Central authentication/onboarding guard.
///
/// - While the session is resolving (auto-login), stay on the splash screen.
/// - Unauthenticated users may only reach onboarding/auth routes.
/// - Association to a parish is mandatory: an authenticated user without a
///   parish is steered to "choose parish" (except while confirming or on the
///   one-time welcome screen).
/// - Users with a parish may still open "choose parish" to change it.
String? _redirect(Ref ref, GoRouterState state) {
  final sessionAsync = ref.read(sessionControllerProvider);
  final location = state.matchedLocation;

  if (sessionAsync.isLoading) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final user = sessionAsync.value;

  if (user == null) {
    return _publicOnlyRoutes.contains(location) ? null : AppRoutes.onboarding;
  }

  // Landing from splash or an auth-only route: route to the right home base.
  if (location == AppRoutes.splash || _publicOnlyRoutes.contains(location)) {
    return user.hasParish ? AppRoutes.home : AppRoutes.chooseParish;
  }

  if (location == AppRoutes.welcomeUser) {
    return null;
  }

  // Mandatory parish gate — cannot reach the rest of the app without one.
  if (!user.hasParish &&
      location != AppRoutes.chooseParish &&
      location != AppRoutes.confirmParish) {
    return AppRoutes.chooseParish;
  }

  return null;
}
