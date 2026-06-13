import 'package:go_router/go_router.dart';
import 'package:pustakalaya/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:pustakalaya/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:pustakalaya/features/cart/presentation/screens/cart_screen.dart';
import 'package:pustakalaya/features/filter/presentation/screens/filter_screen.dart';
import 'package:pustakalaya/features/navbar/app_shell.dart';
import 'package:pustakalaya/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:pustakalaya/features/onboarding/presentation/pages/onboarding_screen.dart';
// import 'package:pustakalaya/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:pustakalaya/features/search/presentation/screens/search_screen.dart';
import 'package:pustakalaya/features/splash/presentation/pages/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash         = '/';
  static const String onboarding     = '/onboarding';
  static const String signUp         = '/sign-up';
  static const String signIn         = '/sign-in';
  static const String home           = '/home';
  static const String myOrders       = '/my-orders';
  static const String orderDetail    = '/order-detail';
  static const String bookDetail     = '/book-detail';
  static const String cart           = '/cart';
  static const String checkout       = '/checkout';
  static const String confirmation   = '/confirmation';
  static const String trackOrder     = '/track-order';
  static const String notifications  = '/notifications';
  static const String search         = '/search';
  static const String filter         = '/filter';

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
      // GoRoute(path: myOrders,
      //     builder: (_, __) => const MyOrdersScreen()),
      // GoRoute(
      //   path: orderDetail,
      //   builder: (context, state) {
      //     final order = state.extra as OrderItem;
      //     return OrderDetailScreen(order: order);
      //   },
      // ),
      GoRoute(path: bookDetail,
          builder: (_, __) => const BookDetailScreen()),
      GoRoute(path: cart,
          builder: (_, __) => const CartScreen()),
      // Canonical checkout — reads cart total via cartTotalProvider directly.
      // GoRoute(
      //   path: checkout,
      //   builder: (_, __) => const CheckoutScreen(),
      // ),
      // GoRoute(
      //   path: confirmation,
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>?;
      //     final orderId = (extra?['orderId'] as String?) ?? '#FS-00000';
      //     final total = (extra?['total'] as double?) ?? 0.0;
      //     final paymentMethod = (extra?['paymentMethod'] as String?) ?? '';
      //     final bookTitle = (extra?['bookTitle'] as String?) ?? 'Your Order';
      //     final bookAuthor = (extra?['bookAuthor'] as String?) ?? '';
      //     final bookColor = (extra?['bookColor'] as String?) ?? '#E8602C';
      //     final placedDate = (extra?['placedDate'] as String?) ?? '';
      //     return ConfirmationScreen(
      //       orderId: orderId,
      //       total: total,
      //       paymentMethod: paymentMethod,
      //       bookTitle: bookTitle,
      //       bookAuthor: bookAuthor,
      //       bookColor: bookColor,
      //       placedDate: placedDate,
      //     );
      //   },
      // ),
      // GoRoute(
      //   path: trackOrder,
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>?;
      //     return TrackOrderScreen(
      //       orderId: (extra?['orderId'] as String?) ?? '#FS-00000',
      //       total: (extra?['total'] as double?) ?? 0.0,
      //       paymentMethod: (extra?['paymentMethod'] as String?) ?? '',
      //       bookTitle: (extra?['bookTitle'] as String?) ?? 'Your Order',
      //       bookAuthor: (extra?['bookAuthor'] as String?) ?? '',
      //       bookColor: (extra?['bookColor'] as String?) ?? '#E8602C',
      //       placedDate: (extra?['placedDate'] as String?) ?? '',
      //     );
      //   },
      // ),
      GoRoute(path: notifications,
          builder: (_, __) => const NotificationsScreen()),
      // Search accepts an optional pre-filter section from Home 'See all'.
      GoRoute(
        path: search,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final initialSection = extra?['section'] as String?;
          return SearchScreen(initialSection: initialSection);
        },
      ),
      GoRoute(path: filter,
          builder: (_, __) => const FilterScreen()),
    ],
  );
}

