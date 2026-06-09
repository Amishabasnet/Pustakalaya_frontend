import 'package:go_router/go_router.dart';
import 'package:pustakalaya/features/splash/presentation/screens/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
    ],
  );
}
