import 'package:pustakalaya/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:pustakalaya/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  static const _key = 'onboarding_complete';

  @override
  List<OnboardingPage> getOnboardingPages() => const [
    OnboardingPage(
      title: 'Discover New Books',
      description: 'Explore thousands of books from different genres.',
      illustrationAsset: 'assets/images/onboarding_1.png',
    ),
    OnboardingPage(
      title: 'Order Books Easily',
      description: 'Add to cart and checkout in just few taps.',
      illustrationAsset: 'assets/images/onboarding_2.png',
    ),
    OnboardingPage(
      title: 'Build your Reading List',
      description: 'Save books to wishlist and continue anytime.',
      illustrationAsset: 'assets/images/onboarding_3.png',
    ),
  ];

  @override
  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  @override
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
}
