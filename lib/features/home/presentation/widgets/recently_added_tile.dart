import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/home/presentation/providers/home_provider.dart';
import 'package:pustakalaya/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:pustakalaya/features/home/presentation/widgets/verified_badge.dart';

class RecentlyAddedTile extends ConsumerWidget {
  final BookEntity book;

  const RecentlyAddedTile({super.key, required this.book});

  Color get _coverColor {
    final hex = book.coverColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistItems = ref.watch(wishlistProvider);
    final isWishlisted = wishlistItems.any((i) => i.book.id == book.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Small cover
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 70,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _coverColor,
                    Color.lerp(_coverColor, Colors.black, 0.3)!,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 6, 8),
                    child: Text(
                      book.title,
                      style: GoogleFonts.lato(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
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
                if (book.isVerified) ...[
                  const VerifiedBadge(small: true),
                  const SizedBox(height: 4),
                ],
                Text(
                  book.title,
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
                  book.author,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
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

          // Heart
          GestureDetector(
            onTap: () {
              ref.read(wishlistProvider.notifier).toggle(book);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
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
    );
  }
}
