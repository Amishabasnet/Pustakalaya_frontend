import 'package:go_router/go_router.dart';
import 'package:pustakalaya/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:pustakalaya/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:pustakalaya/features/book_detail/presentation/screens/book_detail_screen.dart';
import 'package:pustakalaya/features/cart/presentation/screens/cart_screen.dart';
import 'package:pustakalaya/features/cart/presentation/screens/checkout/checkout_screen.dart';
import 'package:pustakalaya/features/cart/presentation/screens/checkout/confirmation_screen.dart';
import 'package:pustakalaya/features/navbar/app_shell.dart';
import 'package:pustakalaya/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:pustakalaya/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:pustakalaya/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:pustakalaya/features/splash/presentation/pages/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash         = '/';
  static const String onboarding     = '/onboarding';
  static const String signUp         = '/sign-up';
  static const String signIn         = '/sign-in';
  static const String home           = '/home';
  static const String myOrders       = '/my-orders';
  static const String bookDetail     = '/book-detail';
  static const String cart           = '/cart';
  static const String checkout       = '/checkout';
  static const String confirmation   = '/confirmation';
  static const String notifications  = '/notifications';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash,
          builder: (_, __) => const SplashScreen()),
      GoRoute(path: onboarding,
          builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: signUp,
          builder: (_, __) => const SignUpScreen()),
      GoRoute(path: signIn,
          builder: (_, __) => const SignInScreen()),
      GoRoute(path: home,
          builder: (_, __) => const AppShell()),
      GoRoute(path: myOrders,
          builder: (_, __) => const MyOrdersScreen()),
      GoRoute(path: bookDetail,
          builder: (_, __) => const BookDetailScreen()),
      GoRoute(path: cart,
          builder: (_, __) => const CartScreen()),
      GoRoute(
        path: checkout,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final grandTotal = (extra?['grandTotal'] as double?) ?? 0.0;
          return CheckoutScreen(grandTotal: grandTotal);
        },
      ),
      GoRoute(
        path: confirmation,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final orderId = (extra?['orderId'] as String?) ?? '#FS-00000';
          final total = (extra?['total'] as double?) ?? 0.0;
          final paymentMethod = (extra?['paymentMethod'] as String?) ?? '';
          return ConfirmationScreen(
            orderId: orderId,
            total: total,
            paymentMethod: paymentMethod,
          );
        },
      ),
      GoRoute(path: notifications,
          builder: (_, __) => const NotificationsScreen()),
    ],
  );
}
