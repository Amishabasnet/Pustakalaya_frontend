import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:pustakalaya/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:pustakalaya/features/onboarding/domain/repositories/onboarding_repository.dart';

// Repository provider
final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepositoryImpl(),
);

// Pages provider
final onboardingPagesProvider = Provider<List<OnboardingPage>>(
  (ref) => ref.watch(onboardingRepositoryProvider).getOnboardingPages(),
);

// State
class OnboardingState {
  final int currentIndex;
  final bool isComplete;

  const OnboardingState({this.currentIndex = 0, this.isComplete = false});

  OnboardingState copyWith({int? currentIndex, bool? isComplete}) =>
      OnboardingState(
        currentIndex: currentIndex ?? this.currentIndex,
        isComplete: isComplete ?? this.isComplete,
      );
}

// Notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final OnboardingRepository _repository;
  final int _pageCount;

  OnboardingNotifier(this._repository, this._pageCount)
    : super(const OnboardingState());

  Future<void> nextPage() async {
    if (state.currentIndex < _pageCount - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    } else {
      await _completeOnboarding();
    }
  }

  void goToPage(int index) {
    state = state.copyWith(currentIndex: index);
  }

  Future<void> _completeOnboarding() async {
    await _repository.markOnboardingComplete();
    state = state.copyWith(isComplete: true);
  }

  Future<void> skipOnboarding() async {
    await _completeOnboarding();
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      final repo = ref.watch(onboardingRepositoryProvider);
      final pages = ref.watch(onboardingPagesProvider);
      return OnboardingNotifier(repo, pages.length);
    });
