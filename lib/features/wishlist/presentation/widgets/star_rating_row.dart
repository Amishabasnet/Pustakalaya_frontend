import 'package:flutter/material.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';

class StarRatingRow extends StatelessWidget {
  final int rating; // 0-5
  final double size;
  final ValueChanged<int>? onRate;

  const StarRatingRow({
    super.key,
    required this.rating,
    this.size = 20,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: onRate != null ? () => onRate!(i + 1) : null,
          child: Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: filled
                  ? const Color(0xFFE8A020)
                  : AppColors.primary.withOpacity(0.45),
            ),
          ),
        );
      }),
    );
  }
}
