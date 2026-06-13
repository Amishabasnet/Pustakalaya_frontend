enum FilterTab { popular, newReleased, onSale }

extension FilterTabX on FilterTab {
  String get label {
    switch (this) {
      case FilterTab.popular:
        return 'Popular';
      case FilterTab.newReleased:
        return 'New released';
      case FilterTab.onSale:
        return 'On sale';
    }
  }
}

enum PriceRange {
  high, // NRs. 1000+
  medium, // 500-999
  low; // under 500

  String get label {
    switch (this) {
      case PriceRange.high:
        return 'High (NRs. 1,000+)';
      case PriceRange.medium:
        return 'Medium(500-999)';
      case PriceRange.low:
        return 'Low (under 500)';
    }
  }
}

enum DiscountRange {
  upTo10,
  upTo20,
  upTo50;

  String get label {
    switch (this) {
      case DiscountRange.upTo10:
        return 'Up to 10% off';
      case DiscountRange.upTo20:
        return 'Up to 20% off';
      case DiscountRange.upTo50:
        return 'Up to 50% off';
    }
  }
}

class FilterState {
  final FilterTab activeTab;
  final Set<String> selectedWriters;
  final Set<String> selectedGenres;
  final int selectedRating; // 0 = none, 1-5 = star count
  final Set<PriceRange> selectedPrices;
  final Set<DiscountRange> selectedDiscounts;

  const FilterState({
    this.activeTab = FilterTab.popular,
    this.selectedWriters = const {},
    this.selectedGenres = const {},
    this.selectedRating = 0,
    this.selectedPrices = const {},
    this.selectedDiscounts = const {},
  });

  FilterState copyWith({
    FilterTab? activeTab,
    Set<String>? selectedWriters,
    Set<String>? selectedGenres,
    int? selectedRating,
    Set<PriceRange>? selectedPrices,
    Set<DiscountRange>? selectedDiscounts,
  }) => FilterState(
    activeTab: activeTab ?? this.activeTab,
    selectedWriters: selectedWriters ?? this.selectedWriters,
    selectedGenres: selectedGenres ?? this.selectedGenres,
    selectedRating: selectedRating ?? this.selectedRating,
    selectedPrices: selectedPrices ?? this.selectedPrices,
    selectedDiscounts: selectedDiscounts ?? this.selectedDiscounts,
  );

  bool get hasActiveFilters =>
      selectedWriters.isNotEmpty ||
      selectedGenres.isNotEmpty ||
      selectedRating > 0 ||
      selectedPrices.isNotEmpty ||
      selectedDiscounts.isNotEmpty;

  FilterState get cleared => const FilterState();
}
