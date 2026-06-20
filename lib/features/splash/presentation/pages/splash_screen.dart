import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/core/constants/app_text_styles.dart';
import 'package:pustakalaya/core/router/app_router.dart';
import 'package:pustakalaya/features/onboarding/presentation/providers/onboarding_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // Navigate after splash delay, skipping onboarding if already completed.
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final repo = ref.read(onboardingRepositoryProvider);
      final completed = await repo.isOnboardingComplete();
      if (!mounted) return;
      context.go(completed ? AppRouter.home : AppRouter.onboarding);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Book icon placeholder
                Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.only(bottom: 28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                Text('Pustakalaya', style: AppTextStyles.splashTitle),
                const SizedBox(height: 10),
                Text(
                  'YOUR BOOKSTORE, DELIVERED.',
                  style: AppTextStyles.splashSubtitle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
