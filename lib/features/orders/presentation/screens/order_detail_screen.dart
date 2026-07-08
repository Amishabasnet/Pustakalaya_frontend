import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/orders/domain/entities/order_item.dart';
import 'package:pustakalaya/features/orders/presentation/providers/orders_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final OrderItem order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isCancelling = false;

  OrderItem get order => widget.order;

  Color get _coverColor {
    final hex = order.coverColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  bool get _isDark {
    final c = _coverColor;
    return (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255 < 0.55;
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: const Text(
          "This can't be undone. The books will be returned to stock.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isCancelling = true);
    try {
      await cancelOrderAndRefresh(ref, order.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled.')),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't cancel this order. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final hPad = mq.size.width > 600 ? 32.0 : 20.0;
    final coverColor = _coverColor;
    final textOnCover = _isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Order #${order.orderNumber}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEE8E0)),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBanner(status: order.status),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Cover thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 72,
                              height: 96,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    coverColor,
                                    Color.lerp(
                                      coverColor,
                                      _isDark ? Colors.black : Colors.white,
                                      0.30,
                                    )!,
                                  ],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 5,
                                    color: Colors.black.withValues(alpha: 0.20),
                                  ),
                                  Positioned(
                                    top: -10,
                                    right: -10,
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.09),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      9,
                                      9,
                                      6,
                                      7,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.bookTitle,
                                          style: GoogleFonts.lato(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w900,
                                            color: textOnCover,
                                            height: 1.25,
                                          ),
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        Text(
                                          order.bookAuthor,
                                          style: GoogleFonts.lato(
                                            fontSize: 6,
                                            color: textOnCover.withValues(
                                              alpha: 0.75,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.bookTitle,
                                  style: GoogleFonts.lato(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  order.bookAuthor,
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _InfoPill(label: 'Qty: ${order.quantity}'),
                                    const SizedBox(width: 8),
                                    _InfoPill(
                                      label:
                                          'NRs. ${order.price.toStringAsFixed(0)} each',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _OrderTimeline(order: order),

                    const SizedBox(height: 16),

                    _PriceSummary(order: order),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: order.isCancellable
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isCancelling ? null : () => _confirmCancel(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isCancelling
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Cancel Order',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w700,
                              color: Colors.redAccent,
                            ),
                          ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final OrderStatus status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (status) {
      OrderStatus.processing => (
        const Color(0xFFFFF8E8),
        const Color(0xFFF39C12),
        Icons.hourglass_top_rounded,
      ),
      OrderStatus.delivered => (
        const Color(0xFFEAF7EE),
        const Color(0xFF27AE60),
        Icons.check_circle_outline_rounded,
      ),
      OrderStatus.cancelled => (
        const Color(0xFFFFEEEE),
        const Color(0xFFE74C3C),
        Icons.cancel_outlined,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.label,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                switch (status) {
                  OrderStatus.processing => 'Your order is being processed',
                  OrderStatus.delivered => 'Your order has been delivered',
                  OrderStatus.cancelled => 'This order was cancelled',
                },
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: fg.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final OrderItem order;
  const _OrderTimeline({required this.order});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _fmt(DateTime dt) => '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        icon: Icons.receipt_long_outlined,
        label: 'Order Placed',
        date: _fmt(order.orderedAt),
        done: true,
      ),
      _TimelineStep(
        icon: Icons.inventory_2_outlined,
        label: 'Processing',
        date: order.status != OrderStatus.cancelled
            ? 'In progress'
            : 'Cancelled',
        done: order.status != OrderStatus.cancelled,
        active: order.status == OrderStatus.processing,
      ),
      _TimelineStep(
        icon: Icons.local_shipping_outlined,
        label: 'Out for Delivery',
        date: order.deliveredAt != null ? _fmt(order.deliveredAt!) : '—',
        done: order.status == OrderStatus.delivered,
      ),
      _TimelineStep(
        icon: Icons.home_outlined,
        label: 'Delivered',
        date: order.deliveredAt != null ? _fmt(order.deliveredAt!) : '—',
        done: order.status == OrderStatus.delivered,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Timeline',
            style: GoogleFonts.lato(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isLast = i == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: icon + connector line
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: step.done
                            ? AppColors.primary
                            : step.active
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : const Color(0xFFF0EBE5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.icon,
                        size: 15,
                        color: step.done
                            ? Colors.white
                            : step.active
                            ? AppColors.primary
                            : AppColors.textMedium.withValues(alpha: 0.5),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 28,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        color: step.done
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : const Color(0xFFE0D9D2),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                // Right: label + date
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: step.done || step.active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: step.done || step.active
                              ? AppColors.textDark
                              : AppColors.textMedium,
                        ),
                      ),
                      Text(
                        step.date,
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          color: AppColors.textMedium,
                        ),
                      ),
                      if (!isLast) const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final IconData icon;
  final String label;
  final String date;
  final bool done;
  final bool active;
  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.date,
    this.done = false,
    this.active = false,
  });
}

class _PriceSummary extends StatelessWidget {
  final OrderItem order;
  const _PriceSummary({required this.order});

  @override
  Widget build(BuildContext context) {
    const deliveryFee = 120.0;
    final grandTotal = order.total + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: GoogleFonts.lato(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          _PriceRow(
            label: '${order.bookTitle} × ${order.quantity}',
            value: 'NRs. ${order.total.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Delivery fee',
            value: 'NRs. ${deliveryFee.toStringAsFixed(0)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          ),
          _PriceRow(
            label: 'Total',
            value: 'NRs. ${grandTotal.toStringAsFixed(0)}',
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: bold ? AppColors.textDark : AppColors.textMedium,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: bold ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  const _InfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMedium,
        ),
      ),
    );
  }
}
