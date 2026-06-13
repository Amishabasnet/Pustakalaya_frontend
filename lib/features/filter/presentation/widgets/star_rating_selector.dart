import 'package:flutter/material.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';

class StarRatingSelector extends StatelessWidget {
  final int selectedRating; // 0 = none selected
  final ValueChanged<int> onTap;

  const StarRatingSelector({
    super.key,
    required this.selectedRating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final starIndex = i + 1;
        final isSelected = starIndex <= selectedRating;
        return GestureDetector(
          onTap: () => onTap(starIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : const Color(0xFFE8DDD5),
                width: isSelected ? 1.5 : 1.2,
              ),
            ),
            child: Center(
              child: Icon(
                isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 22,
                color: isSelected
                    ? AppColors.primary
                    : const Color(0xFFE8A090),
              ),
            ),
          ),
        );
      }),
    );
  }
}
