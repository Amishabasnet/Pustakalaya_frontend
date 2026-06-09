import 'package:go_router/go_router.dart';
import 'package:pustakalaya/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:pustakalaya/features/splash/presentation/pages/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
}
