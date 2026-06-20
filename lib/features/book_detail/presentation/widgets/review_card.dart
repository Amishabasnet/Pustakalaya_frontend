import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/book_detail/domain/entities/book_detail.dart';

class ReviewCard extends StatelessWidget {
  final BookReview review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF3D3480),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                review.reviewerInitial,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.reviewerName,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                // Stars
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < review.starRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14,
                      color: i < review.starRating
                          ? const Color(0xFFE8A020)
                          : AppColors.primary.withValues(alpha: 0.35),
                    );
                  }),
                ),
                const SizedBox(height: 5),
                Text(
                  review.comment,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    height: 1.5,
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
