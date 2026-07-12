import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pustakalaya/features/auth/presentation/providers/auth_provider.dart';
import 'package:pustakalaya/features/auth/presentation/screens/sign_in_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign-in success navigates to home', (tester) async {
    final router = GoRouter(
      initialLocation: '/sign-in',
      routes: [
        GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    container.read(signInNotifierProvider.notifier).state = const AuthState(
      status: AuthStatus.success,
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
  });
}
