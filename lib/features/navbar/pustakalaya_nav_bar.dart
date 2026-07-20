import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../cart/presentation/providers/cart_provider.dart';

class PustakalayaNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PustakalayaNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      label: 'Home',
    ),
    _NavItem(
      activeIcon: Icons.favorite_rounded,
      inactiveIcon: Icons.favorite_border_rounded,
      label: 'Wishlist',
    ),
    _NavItem(
      activeIcon: Icons.shopping_cart_rounded,
      inactiveIcon: Icons.shopping_cart_outlined,
      label: 'Cart',
    ),
    _NavItem(
      activeIcon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
  ];

  static const int _cartTabIndex = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              final showBadge = i == _cartTabIndex && cartCount > 0;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 26,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                selected ? item.activeIcon : item.inactiveIcon,
                                key: ValueKey(selected),
                                size: 26,
                                color: Colors.white.withValues(
                                  alpha: selected ? 1.0 : 0.65,
                                ),
                              ),
                            ),
                            if (showBadge)
                              Positioned(
                                top: -4,
                                right: -2,
                                child: _CartBadge(count: cartCount),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: Colors.white.withValues(
                            alpha: selected ? 1.0 : 0.65,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  final int count;
  const _CartBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 9 ? '9+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: Colors.red,
        shape: count > 9 ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: count > 9 ? BorderRadius.circular(8) : null,
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}
