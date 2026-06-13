import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pustakalaya/features/cart/presentation/screens/cart_screen.dart';
import 'package:pustakalaya/features/home/presentation/screens/home_screen.dart';
import 'package:pustakalaya/features/profile/presentation/screens/profile_screen.dart';
import 'package:pustakalaya/features/wishlist/presentation/screens/wishlist_screen.dart';

import 'nav_provider.dart';
import 'pustakalaya_nav_bar.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _screens = [
    HomeScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: activeTab,
        children: _screens,
      ),
      bottomNavigationBar: PustakalayaNavBar(
        currentIndex: activeTab,
        onTap: (i) => ref.read(activeTabProvider.notifier).state = i,
      ),
    );
  }
}
