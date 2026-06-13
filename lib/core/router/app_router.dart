import 'package:go_router/go_router.dart';
import 'package:pustakalaya/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:pustakalaya/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:pustakalaya/features/navbar/app_shell.dart';
import 'package:pustakalaya/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:pustakalaya/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:pustakalaya/features/splash/presentation/pages/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signUp = '/sign-up';
  static const String signIn = '/sign-in';
  static const String home = '/home';
  static const String myOrders = '/my-orders';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: signUp, builder: (context, state) => const SignUpScreen()),
      GoRoute(path: signIn, builder: (context, state) => const SignInScreen()),
      GoRoute(path: home, builder: (context, state) => const AppShell()),
      GoRoute(
        path: myOrders,
        builder: (context, state) => const MyOrdersScreen(),
      ),
    ],
  );
}
