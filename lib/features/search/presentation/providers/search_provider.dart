import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/filter/domain/entities/filter_state.dart';
import 'package:pustakalaya/features/filter/presentation/providers/filter_provider.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/home/presentation/providers/home_provider.dart';

final allBooksProvider = Provider<AsyncValue<List<BookEntity>>>((ref) {
  final featured = ref.watch(featuredBooksProvider);
  final recent = ref.watch(recentlyAddedProvider);

  return featured.when(
    data: (f) => recent.when(
      data: (r) {
        // Merge, dedup by id
        final seen = <String>{};
        final all = [...f, ...r].where((b) => seen.add(b.id)).toList();
        return AsyncValue.data(all);
      },
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier()
    : super([
        'Art history',
        'The Alchemist',
        'Atomic Habits',
        'It Ends With Us',
        'Fiction',
      ]);

  void add(String query) {
    if (query.trim().isEmpty) return;
    final updated = [
      query.trim(),
      ...state.where((s) => s.toLowerCase() != query.trim().toLowerCase()),
    ].take(10).toList();
    state = updated;
  }

  void remove(String query) {
    state = state.where((s) => s != query).toList();
  }

  void clearAll() => state = [];
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>(
      (ref) => RecentSearchesNotifier(),
    );

final searchQueryProvider = StateProvider<String>((ref) => '');

final sectionFilterProvider = StateProvider<String?>((ref) => null);

bool _matchesFilter(BookEntity book, FilterState filter) {
  // Writer (matches against author name)
  if (filter.selectedWriters.isNotEmpty &&
      !filter.selectedWriters.any(
        (w) => book.author.toLowerCase() == w.toLowerCase(),
      )) {
    return false;
  }

  if (filter.selectedGenres.isNotEmpty &&
      !filter.selectedGenres.any(
        (g) => book.genre.toLowerCase() == g.toLowerCase(),
      )) {
    return false;
  }

  if (filter.selectedRating > 0 && book.rating < filter.selectedRating) {
    return false;
  }

  if (filter.selectedPrices.isNotEmpty) {
    final matchesPrice = filter.selectedPrices.any((p) {
      switch (p) {
        case PriceRange.high:
          return book.price >= 1000;
        case PriceRange.medium:
          return book.price >= 500 && book.price <= 999;
        case PriceRange.low:
          return book.price < 500;
      }
    });
    if (!matchesPrice) return false;
  }

  return true;
}

final searchResultsProvider = Provider<List<BookEntity>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final allAsync = ref.watch(allBooksProvider);
  final filter = ref.watch(filterProvider);

  if (query.isEmpty) return [];

  return allAsync.maybeWhen(
    data: (books) => books
        .where(
          (b) =>
              b.title.toLowerCase().contains(query) ||
              b.author.toLowerCase().contains(query) ||
              b.genre.toLowerCase().contains(query),
        )
        .where((b) => _matchesFilter(b, filter))
        .toList(),
    orElse: () => [],
  );
});

final filteredBrowseProvider = Provider<AsyncValue<List<BookEntity>>>((ref) {
  final allAsync = ref.watch(allBooksProvider);
  final filter = ref.watch(filterProvider);

  return allAsync.whenData((books) {
    if (!filter.hasActiveFilters) {
      final sorted = [...books]..sort((a, b) => b.rating.compareTo(a.rating));
      return sorted.take(6).toList();
    }
    return books.where((b) => _matchesFilter(b, filter)).toList();
  });
});

final highlyRecommendedProvider = Provider<AsyncValue<List<BookEntity>>>((ref) {
  final allAsync = ref.watch(allBooksProvider);
  return allAsync.whenData((books) {
    final sorted = [...books]..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(6).toList();
  });
});
