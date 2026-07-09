import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pustakalaya/features/cart/presentation/screens/cart_screen.dart';
import 'package:pustakalaya/features/home/presentation/screens/home_screen.dart';
import 'package:pustakalaya/features/profile/presentation/screens/profile_screen.dart';
import 'package:pustakalaya/features/wishlist/presentation/screens/wishlist_screen.dart';

import 'nav_provider.dart';
import 'pustakalaya_nav_bar.dart';

class AppShell extends ConsumerStatefulWidget {
  /// Which tab to land on when this shell is first built — used so
  /// deep-linking straight to `/wishlist` or `/profile` (a refresh, a
  /// bookmark, a typed URL) opens the right tab instead of always
  /// defaulting to Home.
  final int initialTab;

  const AppShell({super.key, this.initialTab = 0});

  static const _screens = [
    HomeScreen(),
    WishlistScreen(),
    CartScreen(showBackButton: false),
    ProfileScreen(),
  ];

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    if (widget.initialTab != 0) {
      // Deferred to after the first frame — setting provider state
      // synchronously during initState/build can trigger Riverpod's
      // "modified a provider while the widget tree was building" error.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(activeTabProvider.notifier).state = widget.initialTab;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(activeTabProvider);

    return Scaffold(
      body: IndexedStack(index: activeTab, children: AppShell._screens),
      bottomNavigationBar: PustakalayaNavBar(
        currentIndex: activeTab,
        onTap: (i) => ref.read(activeTabProvider.notifier).state = i,
      ),
    );
  }
}
