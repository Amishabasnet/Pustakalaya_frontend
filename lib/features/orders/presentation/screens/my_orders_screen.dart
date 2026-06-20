import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/core/router/app_router.dart';
import 'package:pustakalaya/features/orders/domain/entities/order_item.dart';
import 'package:pustakalaya/features/orders/presentation/providers/orders_provider.dart';
import 'package:pustakalaya/features/orders/presentation/widgets/order_card.dart';
import 'package:pustakalaya/features/orders/presentation/widgets/order_tab_bar.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(orderTabProvider));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    ref.read(orderTabProvider.notifier).state = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(orderTabProvider);
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'My orders',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE8DDD5), width: 1.2),
                ),
              ),
              child: OrderTabBar(activeIndex: activeTab, onTap: _onTabTap),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ordersAsync.when(
                data: (allOrders) {
                  final processingOrders = allOrders
                      .where((o) => o.status.isProcessing)
                      .toList();
                  final deliveredOrders = allOrders
                      .where((o) => o.status.isDelivered)
                      .toList();

                  final pages = [allOrders, processingOrders, deliveredOrders];

                  return PageView.builder(
                    controller: _pageController,
                    itemCount: 3,
                    onPageChanged: (i) =>
                        ref.read(orderTabProvider.notifier).state = i,
                    itemBuilder: (context, pageIndex) {
                      final orders = pages[pageIndex];
                      if (orders.isEmpty) {
                        return _EmptyState(tabIndex: pageIndex);
                      }
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        itemCount: orders.length,
                        itemBuilder: (_, i) => OrderCard(
                          order: orders[i],
                          onTap: () {
                            context.push(
                              AppRouter.orderDetail,
                              extra: orders[i],
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount: 3,
                  itemBuilder: (_, __) => const _ShimmerOrderCard(),
                ),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 52,
                        color: AppColors.textMedium.withOpacity(0.35),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load orders',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int tabIndex;
  const _EmptyState({required this.tabIndex});

  String get _title {
    switch (tabIndex) {
      case 1:
        return 'No orders in processing';
      case 2:
        return 'No delivered orders yet';
      default:
        return 'No orders placed yet';
    }
  }

  String get _subtitle {
    switch (tabIndex) {
      case 1:
        return 'Orders being processed will show here';
      case 2:
        return 'Your completed orders will appear here';
      default:
        return 'Browse books and place your first order!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                tabIndex == 2
                    ? Icons.local_shipping_outlined
                    : Icons.shopping_bag_outlined,
                size: 40,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerOrderCard extends StatefulWidget {
  const _ShimmerOrderCard();

  @override
  State<_ShimmerOrderCard> createState() => _ShimmerOrderCardState();
}

class _ShimmerOrderCardState extends State<_ShimmerOrderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        height: 108,
        decoration: BoxDecoration(
          color: Colors.grey[300]!.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
