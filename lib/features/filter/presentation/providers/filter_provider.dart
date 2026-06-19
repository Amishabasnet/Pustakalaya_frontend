import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/filter/domain/entities/filter_state.dart';

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setTab(FilterTab tab) => state = state.copyWith(activeTab: tab);

  void toggleWriter(String writer) {
    final updated = Set<String>.from(state.selectedWriters);
    updated.contains(writer) ? updated.remove(writer) : updated.add(writer);
    state = state.copyWith(selectedWriters: updated);
  }

  void toggleGenre(String genre) {
    final updated = Set<String>.from(state.selectedGenres);
    updated.contains(genre) ? updated.remove(genre) : updated.add(genre);
    state = state.copyWith(selectedGenres: updated);
  }

  void setRating(int rating) {
    // Tap same rating = deselect
    state = state.copyWith(
      selectedRating: state.selectedRating == rating ? 0 : rating,
    );
  }

  void togglePrice(PriceRange price) {
    final updated = Set<PriceRange>.from(state.selectedPrices);
    updated.contains(price) ? updated.remove(price) : updated.add(price);
    state = state.copyWith(selectedPrices: updated);
  }

  void toggleDiscount(DiscountRange discount) {
    final updated = Set<DiscountRange>.from(state.selectedDiscounts);
    updated.contains(discount)
        ? updated.remove(discount)
        : updated.add(discount);
    state = state.copyWith(selectedDiscounts: updated);
  }

  void reset() => state = state.cleared;
  void resetAll() => state = const FilterState();
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (ref) => FilterNotifier(),
);
