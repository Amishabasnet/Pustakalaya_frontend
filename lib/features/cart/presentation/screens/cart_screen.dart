import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/core/router/app_router.dart';
import 'package:pustakalaya/features/cart/presentation/providers/cart_provider.dart';
import 'package:pustakalaya/features/wishlist/presentation/providers/wishlist_provider.dart';

class CartScreen extends ConsumerWidget {
  final bool showBackButton;

  const CartScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final wishlistItems = ref.watch(wishlistProvider);
    const deliveryFee = 120.0;
    final grandTotal = total + deliveryFee;
    final screenW = MediaQuery.of(context).size.width;
    final hPad = screenW > 600 ? 32.0 : 16.0;

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
                  showBackButton
                      ? _AppBarBtn(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.of(context).maybePop(),
                        )
                      : const SizedBox(width: 36),
                  Expanded(
                    child: Text('Cart',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )),
                  ),
                  _AppBarBtn(
                    icon: Icons.delete_outline_rounded,
                    onTap: items.isEmpty
                        ? () {}
                        : () => _confirmClear(context, ref),
                    invisible: items.isEmpty,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEE8E0)),

            Expanded(
              child: items.isEmpty
                  ? _EmptyState()
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding:
                          EdgeInsets.fromLTRB(hPad, 16, hPad, 100),
                      children: [
                        ...items.map((item) {
                          final book = item.book;
                          final hex =
                              book.coverColor.replaceFirst('#', '');
                          final coverColor =
                              Color(int.parse('FF$hex', radix: 16));
                          final isDark = _isDark(coverColor);
                          final isWishlisted = wishlistItems
                              .any((w) => w.book.id == book.id);

                          return _BookCard(
                            item: item,
                            coverColor: coverColor,
                            isDark: isDark,
                            isWishlisted: isWishlisted,
                            onIncrement: () => ref
                                .read(cartProvider.notifier)
                                .increment(book.id),
                            onDecrement: () => ref
                                .read(cartProvider.notifier)
                                .decrement(book.id),
                            onRemove: () => ref
                                .read(cartProvider.notifier)
                                .remove(book.id),
                            onWishlistToggle: () => ref
                                .read(wishlistProvider.notifier)
                                .toggle(book),
                          );
                        }),
                        const SizedBox(height: 14),

                        _CartSummaryCard(
                          itemCount: items.fold(
                              0, (s, i) => s + i.quantity),
                          subtotal: total,
                          deliveryFee: deliveryFee,
                          grandTotal: grandTotal,
                        ),
                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7EE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF27AE60)
                                    .withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.shield_outlined,
                                  size: 20,
                                  color: Color(0xFF27AE60)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Transparent pricing - no hidden charges',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF27AE60),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad,
                  MediaQuery.of(context).padding.bottom + 12),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      _showProceedDialog(context, ref, grandTotal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'PROCESS TO CHECKOUT',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  bool _isDark(Color c) =>
      (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255 < 0.55;

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('Clear cart?',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('All items will be removed.',
                style: GoogleFonts.lato(
                    fontSize: 13, color: AppColors.textMedium)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Cancel',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).clear();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Clear',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showProceedDialog(
      BuildContext context, WidgetRef ref, double grandTotal) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_cart_checkout_rounded,
                    size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              // Title
              Text(
                'Proceed to Checkout?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                'Are you sure you want to proceed\nwith your order?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 26),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(AppRouter.checkout);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Yes, Proceed',
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool invisible;
  const _AppBarBtn(
      {required this.icon,
      required this.onTap,
      this.invisible = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: invisible ? null : onTap,
      child: AnimatedOpacity(
        opacity: invisible ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final dynamic item;
  final Color coverColor;
  final bool isDark;
  final bool isWishlisted;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final VoidCallback onWishlistToggle;

  const _BookCard({
    required this.item,
    required this.coverColor,
    required this.isDark,
    required this.isWishlisted,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    final book = item.book;
    final textOnCover = isDark ? Colors.white : Colors.black87;

    return Dismissible(
      key: Key(book.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 26),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.055),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 82,
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(coverColor, Colors.white, 0.1)!,
                      coverColor,
                      Color.lerp(coverColor, Colors.black, 0.28)!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                        width: 7,
                        color: Colors.black.withOpacity(0.2)),
                    Positioned(
                      top: -14,
                      right: -14,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.09),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(11, 11, 7, 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title.toUpperCase(),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: textOnCover,
                              height: 1.2,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            book.author,
                            style: GoogleFonts.lato(
                              fontSize: 7,
                              color: textOnCover.withOpacity(0.75),
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
                    book.title,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Verified badge
                  if (book.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8EE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              size: 12,
                              color: Color(0xFF27AE60)),
                          const SizedBox(width: 3),
                          Text('Verified',
                              style: GoogleFonts.lato(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF27AE60),
                              )),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Rating
                  Row(children: [
                    Icon(Icons.star_outline_rounded,
                        size: 15,
                        color: AppColors.primary.withOpacity(0.6)),
                    const SizedBox(width: 3),
                    Text(
                      book.rating.toStringAsFixed(1),
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  // Price
                  Text(
                    'NRs.${(book.price * item.quantity).toStringAsFixed(0)}',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Qty stepper
                  _QuantityStepper(
                    quantity: item.quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                  ),
                ],
              ),
            ),

            // Heart
            GestureDetector(
              onTap: onWishlistToggle,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  isWishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 22,
                  color: isWishlisted ? Colors.red : AppColors.textMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  final int itemCount;
  final double subtotal;
  final double deliveryFee;
  final double grandTotal;

  const _CartSummaryCard({
    required this.itemCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cart Summary',
              style: GoogleFonts.lato(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 16),
          _Row(label: 'Items', value: '$itemCount'),
          const SizedBox(height: 10),
          _Row(
              label: 'Subtotal',
              value: 'NRs. ${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          _Row(
              label: 'Delivery',
              value: 'NRs. ${deliveryFee.toStringAsFixed(0)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1,
                color: Color(0xFFEEEEEE)),
          ),
          _Row(
            label: 'Total',
            value: 'NRs. ${grandTotal.toStringAsFixed(0)}',
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Row(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.lato(
                fontSize: bold ? 15 : 13,
                fontWeight:
                    bold ? FontWeight.w800 : FontWeight.w500,
                color: bold
                    ? AppColors.textDark
                    : AppColors.textMedium)),
        Text(value,
            style: GoogleFonts.lato(
                fontSize: bold ? 15 : 13,
                fontWeight:
                    bold ? FontWeight.w800 : FontWeight.w500,
                color: AppColors.textDark)),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  const _QuantityStepper(
      {required this.quantity,
      required this.onIncrement,
      required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            Border.all(color: AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('$quantity',
                style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ),
          _Btn(icon: Icons.add, onTap: onIncrement, filled: true),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _Btn(
      {required this.icon,
      required this.onTap,
      this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon,
            size: 14,
            color: filled ? Colors.white : AppColors.textMedium),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
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
            child: Icon(Icons.shopping_cart_outlined,
                size: 44,
                color: AppColors.primary.withOpacity(0.7)),
          ),
          const SizedBox(height: 18),
          Text('Your cart is empty',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text('Add books from the Book Detail page!',
              style: GoogleFonts.lato(
                  fontSize: 13, color: AppColors.textMedium)),
        ],
      ),
    );
  }
}
