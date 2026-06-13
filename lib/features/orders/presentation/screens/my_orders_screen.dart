import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/order_tab_bar.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(orderTabProvider);
    final filteredAsync = ref.watch(filteredOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Text(
                'My orders',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE0D5CA), width: 1.2),
                  ),
                ),
                child: OrderTabBar(
                  activeIndex: activeTab,
                  onTap: (i) => ref.read(orderTabProvider.notifier).state = i,
                ),
              ),
            ),

            Expanded(
              child: filteredAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return _EmptyState(activeTab: activeTab);
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    itemCount: orders.length,
                    itemBuilder: (context, i) => OrderCard(
                      order: orders[i],
                      onTap: () {
                        // Navigate to order detail
                      },
                    ),
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: 3,
                  itemBuilder: (_, __) => const _ShimmerOrderCard(),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.textMedium.withOpacity(0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load orders',
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
  final int activeTab;
  const _EmptyState({required this.activeTab});

  String get _message {
    switch (activeTab) {
      case 1:
        return 'No orders being processed';
      case 2:
        return 'No delivered orders yet';
      default:
        return 'You haven\'t placed any orders yet';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 40,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _message,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your orders will appear here',
            style: GoogleFonts.lato(fontSize: 13, color: AppColors.textMedium),
          ),
        ],
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
    _anim = Tween(begin: 0.4, end: 0.9).animate(_ctrl);
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
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        height: 118,
        decoration: BoxDecoration(
          color: Colors.grey[300]!.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
