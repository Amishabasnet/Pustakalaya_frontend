import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

class RecommendedBookCard extends ConsumerWidget {
  final BookEntity book;
  final VoidCallback onTap;

  const RecommendedBookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  Color get _coverColor {
    final hex = book.coverColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  bool get _isDark {
    final c = _coverColor;
    return (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255 < 0.55;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textOnCover = _isDark ? Colors.white : Colors.black87;
    final screenW = MediaQuery.of(context).size.width;
    final cardW = (screenW - 52) / 2; // 2 cols with padding
    final coverH = cardW * 1.35;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: cardW,
              height: coverH,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(_coverColor, Colors.white, 0.15)!,
                    _coverColor,
                    Color.lerp(_coverColor, Colors.black, 0.25)!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Spine
                  Container(width: 8, color: Colors.black.withValues(alpha: 0.18)),
                  // Decor circles
                  Positioned(
                    top: -24,
                    right: -24,
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
                    bottom: -16,
                    left: -16,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Title on cover
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 16, 10, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title.toUpperCase(),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: textOnCover,
                            height: 1.2,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 1.5,
                          width: 28,
                          color: textOnCover.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.author,
                          style: GoogleFonts.lato(
                            fontSize: 10,
                            color: textOnCover.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
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
          const SizedBox(height: 7),

          Text(
            book.title,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),

          Row(
            children: [
              const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                book.rating.toStringAsFixed(1),
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '•',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'NRs.${book.price.toStringAsFixed(0)}',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
