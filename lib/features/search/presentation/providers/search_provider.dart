import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/core/network/api_exception.dart';
import 'package:pustakalaya/features/filter/domain/entities/filter_state.dart';
import 'package:pustakalaya/features/filter/presentation/providers/filter_provider.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/home/presentation/providers/home_provider.dart';
import 'package:pustakalaya/features/search/data/repositories/search_repository_impl.dart';
import 'package:pustakalaya/features/search/domain/repositories/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepositoryImpl(),
);

// Kept for the "Featured" / "Recently added" section shortcuts on the
// search screen, which still just reuse the home catalog.
final allBooksProvider = Provider<AsyncValue<List<BookEntity>>>((ref) {
  final featured = ref.watch(featuredBooksProvider);
  final recent = ref.watch(recentlyAddedProvider);

  return featured.when(
    data: (f) => recent.when(
      data: (r) {
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

/// Recent searches, backed by the account's search history on the server.
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  final SearchRepository _repo;
  RecentSearchesNotifier(this._repo) : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      state = await _repo.getRecentSearches();
    } on ApiException {
      // Not signed in, or request failed — just show an empty history.
      state = [];
    }
  }

  /// The backend records history automatically whenever `search()` is
  /// called with a query while signed in, so this just refreshes the
  /// locally-cached list to match.
  void add(String query) => refresh();

  Future<void> remove(String query) async {
    state = state.where((s) => s != query).toList();
    try {
      await _repo.removeRecentSearch(query);
    } on ApiException {
      await refresh();
    }
  }

  Future<void> clearAll() async {
    state = [];
    try {
      await _repo.clearRecentSearches();
    } on ApiException {
      await refresh();
    }
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>(
      (ref) => RecentSearchesNotifier(ref.watch(searchRepositoryProvider)),
    );

final searchQueryProvider = StateProvider<String>((ref) => '');

final sectionFilterProvider = StateProvider<String?>((ref) => null);

class SearchResultsState {
  final List<BookEntity> books;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;

  const SearchResultsState({
    this.books = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
  });

  SearchResultsState copyWith({
    List<BookEntity>? books,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
  }) => SearchResultsState(
    books: books ?? this.books,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    page: page ?? this.page,
  );
}

/// Live, paginated search against the full catalog on the server — resets
/// and reloads page 1 whenever the query or filter changes, and supports
/// `loadMore()` for infinite scroll.
class SearchResultsNotifier extends StateNotifier<SearchResultsState> {
  final SearchRepository _repo;
  final String _query;
  final FilterState _filter;
  final void Function() _onSearched;

  SearchResultsNotifier(this._repo, this._query, this._filter, this._onSearched)
    : super(const SearchResultsState()) {
    if (_query.trim().isNotEmpty) loadMore();
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final page = await _repo.search(_query, _filter, page: nextPage);
    _onSearched();

    state = state.copyWith(
      books: [...state.books, ...page.books],
      page: page.page,
      hasMore: page.hasMore,
      isLoadingMore: false,
    );
  }
}

final searchResultsProvider =
    StateNotifierProvider.autoDispose<
      SearchResultsNotifier,
      SearchResultsState
    >((ref) {
      final query = ref.watch(searchQueryProvider);
      final filter = ref.watch(filterProvider);
      return SearchResultsNotifier(
        ref.watch(searchRepositoryProvider),
        query,
        filter,
        () => ref.read(recentSearchesProvider.notifier).refresh(),
      );
    });

/// Backs the three filter tabs (Popular / New released / On sale).
final filteredBrowseProvider = FutureProvider.autoDispose<List<BookEntity>>((
  ref,
) async {
  final filter = ref.watch(filterProvider);
  final repo = ref.watch(searchRepositoryProvider);

  switch (filter.activeTab) {
    case FilterTab.popular:
      return repo.getPopular(filter);
    case FilterTab.newReleased:
      return repo.getNewReleased(filter);
    case FilterTab.onSale:
      return repo.getOnSale(filter);
  }
});

final highlyRecommendedProvider = FutureProvider.autoDispose<List<BookEntity>>((
  ref,
) {
  return ref.watch(searchRepositoryProvider).getHighlyRecommended();
});
