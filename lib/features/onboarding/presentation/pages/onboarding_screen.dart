import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/core/constants/app_text_styles.dart';
import 'package:pustakalaya/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:pustakalaya/features/onboarding/presentation/widgets/onboarding_dot_indicator.dart';
import 'package:pustakalaya/features/onboarding/presentation/widgets/onboarding_page_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final state = ref.read(onboardingNotifierProvider);
    final pages = ref.read(onboardingPagesProvider);

    if (state.currentIndex < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      notifier.nextPage();
    } else {
      notifier.nextPage(); // triggers isComplete = true
    }
  }

  void _onSkip() {
    ref.read(onboardingNotifierProvider.notifier).skipOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(onboardingPagesProvider);
    final state = ref.watch(onboardingNotifierProvider);
    final isLastPage = state.currentIndex == pages.length - 1;

    // React to onboarding completion
    ref.listen(onboardingNotifierProvider, (prev, next) {
      if (next.isComplete && mounted) {
        // Navigate to your home screen here
        // e.g. context.go(AppRouter.home);
        // For now, show a snack bar as placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Onboarding complete! Navigate to Home.'),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page counter
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '${state.currentIndex + 1}/${pages.length}',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  // Skip button
                  if (!isLastPage)
                    TextButton(
                      onPressed: _onSkip,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.onboardingBody.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 64),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  ref.read(onboardingNotifierProvider.notifier).goToPage(index);
                },
                itemBuilder: (context, index) =>
                    OnboardingPageCard(page: pages[index], index: index),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
              child: Column(
                children: [
                  OnboardingDotIndicator(
                    count: pages.length,
                    activeIndex: state.currentIndex,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastPage ? 'Get Started' : 'Next',
                            style: AppTextStyles.buttonLabel,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLastPage
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
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
