import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:pustakalaya/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:pustakalaya/features/wishlist/presentation/widgets/star_rating_row.dart';


class WishlistBookCard extends ConsumerWidget {
  final WishlistItem item;

  const WishlistBookCard({super.key, required this.item});

  Color get _coverColor {
    final hex = item.book.coverColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  bool get _isDark {
    // Determine if the cover color is dark to choose text colour
    final c = _coverColor;
    final luminance = (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255;
    return luminance < 0.55;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Book cover 
            _BookCover(color: _coverColor, isDark: _isDark, item: item),
            const SizedBox(width: 14),

            // Info 
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.book.title,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'By ${item.book.author}',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Star rating row
                  StarRatingRow(
                    rating: item.userRating,
                    size: 20,
                    onRate: (r) => ref
                        .read(wishlistProvider.notifier)
                        .setRating(item.book.id, r),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NRs. ${item.book.price.toStringAsFixed(0)}',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Heart button 
            GestureDetector(
              onTap: () => ref
                  .read(wishlistProvider.notifier)
                  .remove(item.book.id),
              child: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  final Color color;
  final bool isDark;
  final WishlistItem item;

  const _BookCover({
    required this.color,
    required this.isDark,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 72,
        height: 96,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              Color.lerp(color, isDark ? Colors.black : Colors.white, 0.28)!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Spine
            Container(
              width: 6,
              color: Colors.black.withValues(alpha: 0.18),
            ),
            // Decorative circle
            Positioned(
              top: -12,
              right: -12,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Title text on cover
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 6, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.book.title,
                    style: GoogleFonts.lato(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      height: 1.25,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    item.book.author,
                    style: GoogleFonts.lato(
                      fontSize: 7,
                      color: textColor.withValues(alpha: 0.75),
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
    );
  }
}
