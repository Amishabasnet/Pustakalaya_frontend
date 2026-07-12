import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:pustakalaya/features/home/presentation/widgets/verified_badge.dart';

class FeaturedBookCard extends ConsumerWidget {
  final BookEntity book;

  const FeaturedBookCard({super.key, required this.book});

  Color get _coverColor {
    final hex = book.coverColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistItems = ref.watch(wishlistProvider);
    final isWishlisted = wishlistItems.any((i) => i.book.id == book.id);
    final screenW = MediaQuery.of(context).size.width;
    // Responsive card width: ~42% of screen, min 150, max 180
    final cardW = (screenW * 0.42).clamp(150.0, 185.0);
    final coverH = cardW * 1.28;

    return Container(
      width: cardW,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              children: [
                _BookCoverIllustration(
                  book: book,
                  color: _coverColor,
                  height: coverH,
                  width: cardW,
                ),
                // Heart button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(wishlistProvider.notifier).toggle(book);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: isWishlisted ? Colors.red : AppColors.textMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info section
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (book.isVerified) ...[
                  const VerifiedBadge(),
                  const SizedBox(height: 4),
                ],
                Text(
                  book.title,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  book.author,
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'NRs. ${book.price.toStringAsFixed(0)}',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Illustrated book cover with gradient + title text
class _BookCoverIllustration extends StatelessWidget {
  final BookEntity book;
  final Color color;
  final double height;
  final double width;

  const _BookCoverIllustration({
    required this.book,
    required this.color,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (book.coverImageUrl != null) {
      return SizedBox(
        width: width,
        height: height,
        child: Image.network(
          book.coverImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _illustration(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _illustration();
          },
        ),
      );
    }
    return _illustration();
  }

  Widget _illustration() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.35)!],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: -15,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Spine
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 8,
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
          // Title on cover
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title.toUpperCase(),
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1.5,
                  width: 32,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  book.author,
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
