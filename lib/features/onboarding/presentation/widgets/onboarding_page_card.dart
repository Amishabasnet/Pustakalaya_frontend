import 'package:flutter/material.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/core/constants/app_text_styles.dart';
import 'package:pustakalaya/features/onboarding/domain/entities/onboarding_page.dart';

class OnboardingPageCard extends StatelessWidget {
  final OnboardingPage page;
  final int index;

  const OnboardingPageCard({
    super.key,
    required this.page,
    required this.index,
  });

  // Unique accent icon per page
  static const _icons = [
    Icons.auto_stories_rounded,
    Icons.shopping_cart_checkout_rounded,
    Icons.bookmark_added_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder
          Container(
            width: 200,
            height: 200,
            margin: const EdgeInsets.only(bottom: 52),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _icons[index % _icons.length],
              size: 80,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),

          Text(
            page.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingTitle,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingBody,
          ),
        ],
      ),
    );
  }
}
