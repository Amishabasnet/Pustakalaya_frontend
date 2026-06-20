import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/book_detail/presentation/providers/book_detail_provider.dart';
import 'package:pustakalaya/features/book_detail/presentation/widgets/accordion_section.dart';
import 'package:pustakalaya/features/book_detail/presentation/widgets/quantity_stepper.dart';
import 'package:pustakalaya/features/book_detail/presentation/widgets/review_card.dart';
import 'package:pustakalaya/features/cart/presentation/providers/cart_provider.dart';
import 'package:pustakalaya/features/wishlist/presentation/providers/wishlist_provider.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(bookDetailProvider);
    final quantity = ref.watch(bookQuantityProvider);
    final accordion = ref.watch(accordionProvider);
    final wishlistItems = ref.watch(wishlistProvider);

    if (detail == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final book = detail.book;
    final coverHex = book.coverColor.replaceFirst('#', '');
    final coverColor = Color(int.parse('FF$coverHex', radix: 16));
    final isDark = _isDarkColor(coverColor);
    final textOnCover = isDark ? Colors.white : Colors.black87;
    final isWishlisted = wishlistItems.any((i) => i.book.id == book.id);

    final screenW = MediaQuery.of(context).size.width;
    final coverH = (screenW * 0.62).clamp(200.0, 320.0);
    final hPad = screenW > 600 ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Cover background
                    Container(
                      width: double.infinity,
                      height: coverH,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(coverColor, Colors.white, 0.15)!,
                            coverColor,
                            Color.lerp(coverColor, Colors.black, 0.25)!,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Decorative circles
                          Positioned(
                            top: -40,
                            left: -40,
                            child: _DecorCircle(
                              size: 160,
                              opacity: isDark ? 0.08 : 0.12,
                            ),
                          ),
                          Positioned(
                            bottom: -30,
                            right: -30,
                            child: _DecorCircle(
                              size: 140,
                              opacity: isDark ? 0.06 : 0.10,
                            ),
                          ),
                          // Book title on cover
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: hPad + 20,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    book.title.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: screenW > 600 ? 42 : 34,
                                      fontWeight: FontWeight.w900,
                                      color: textOnCover,
                                      height: 1.1,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    book.author.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: textOnCover.withValues(
                                        alpha: 0.75,
                                      ),
                                      letterSpacing: 2.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // AppBar overlay
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _AppBarBtn(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.of(context).maybePop(),
                            ),
                            Text(
                              'Book Detail',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textOnCover,
                              ),
                            ),
                            _AppBarBtn(
                              icon: Icons.ios_share_rounded,
                              onTap: () {},
                              iconColor: textOnCover,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Quantity stepper — bottom right of cover
                    Positioned(
                      bottom: 14,
                      right: 16,
                      child: QuantityStepper(
                        quantity: quantity,
                        onIncrement: () {
                          ref.read(bookQuantityProvider.notifier).state =
                              quantity + 1;
                        },
                        onDecrement: () {
                          if (quantity > 1) {
                            ref.read(bookQuantityProvider.notifier).state =
                                quantity - 1;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + wishlist button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: screenW > 600 ? 26 : 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  book.author,
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Wishlist toggle
                          GestureDetector(
                            onTap: () => ref
                                .read(wishlistProvider.notifier)
                                .toggle(book),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isWishlisted
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite_rounded
                                    : Icons.add,
                                size: 22,
                                color: isWishlisted
                                    ? AppColors.primary
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (detail.isVerifiedSeller)
                            _BadgeChip(
                              icon: Icons.verified_rounded,
                              label: 'Verified Seller',
                              iconColor: const Color(0xFF27AE60),
                              borderColor: const Color(
                                0xFF27AE60,
                              ).withValues(alpha: 0.4),
                              textColor: const Color(0xFF27AE60),
                            ),
                          _BadgeChip(
                            icon: Icons.star_rounded,
                            label: '${book.rating} rating',
                            iconColor: const Color(0xFFE8A020),
                            borderColor: const Color(
                              0xFFE8A020,
                            ).withValues(alpha: 0.4),
                            textColor: AppColors.textDark,
                          ),
                          if (detail.inStock)
                            _BadgeChip(
                              label: 'In Stock',
                              borderColor: const Color(
                                0xFF2E86AB,
                              ).withValues(alpha: 0.4),
                              textColor: const Color(0xFF2E86AB),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Text(
                            'NRs. ${(book.price * quantity).toStringAsFixed(0)}',
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'NRs.${detail.originalPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: AppColors.textMedium,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4EDDA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${detail.discountPercent}% off',
                              style: GoogleFonts.lato(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E8449),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Text(
                        'For $quantity ${quantity == 1 ? 'copy' : 'copies'}  •  Free delivery over NRs.${detail.freeDeliveryThreshold.toStringAsFixed(0)}',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: AccordionSection(
                  title: 'Preview & description',
                  isExpanded: accordion[0] ?? true,
                  onToggle: () => ref.read(accordionProvider.notifier).state = {
                    ...accordion,
                    0: !(accordion[0] ?? true),
                  },
                  child: Text(
                    detail.description,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: AppColors.textMedium,
                      height: 1.65,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: AccordionSection(
                  title: 'Return guarantee',
                  isExpanded: accordion[1] ?? false,
                  onToggle: () => ref.read(accordionProvider.notifier).state = {
                    ...accordion,
                    1: !(accordion[1] ?? false),
                  },
                  child: Text(
                    detail.returnPolicy,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: AppColors.textMedium,
                      height: 1.65,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: AccordionSection(
                  title: 'Reviews (${detail.reviews.length * 64})',
                  isExpanded: accordion[2] ?? true,
                  onToggle: () => ref.read(accordionProvider.notifier).state = {
                    ...accordion,
                    2: !(accordion[2] ?? true),
                  },
                  child: Column(
                    children: detail.reviews
                        .map((r) => ReviewCard(review: r))
                        .toList(),
                  ),
                ),
              ),

              // Bottom padding for sticky button
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add to cart
                        for (var i = 0; i < quantity; i++) {
                          ref.read(cartProvider.notifier).add(book);
                        }
                        // Reset quantity
                        ref.read(bookQuantityProvider.notifier).state = 1;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$quantity ${quantity == 1 ? 'copy' : 'copies'} of "${book.title}" added to cart!',
                              style: GoogleFonts.lato(fontSize: 13),
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'ADD TO CART',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isDarkColor(Color c) {
    final lum = (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255;
    return lum < 0.55;
  }
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _AppBarBtn({required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor ?? Colors.white),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color iconColor;
  final Color borderColor;
  final Color textColor;

  const _BadgeChip({
    this.icon,
    required this.label,
    this.iconColor = Colors.grey,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
