import 'package:pustakalaya/core/network/api_client.dart';
import 'package:pustakalaya/features/filter/domain/entities/filter_state.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final ApiClient _client = ApiClient.instance;

  /// Approximates the UI's multi-select price/rating chips into the single
  /// min/max range the backend query supports.
  Map<String, dynamic> _filterQuery(FilterState filter) {
    final query = <String, dynamic>{};

    if (filter.selectedWriters.isNotEmpty) {
      query['authors'] = filter.selectedWriters.join(',');
    }
    if (filter.selectedGenres.isNotEmpty) {
      query['genres'] = filter.selectedGenres.join(',');
    }
    if (filter.selectedRating > 0) {
      query['minRating'] = filter.selectedRating;
    }
    if (filter.selectedPrices.isNotEmpty) {
      // The backend only supports a single contiguous [min, max] range, so
      // multiple selections are approximated as the widest envelope that
      // covers all of them (may include a small gap between non-adjacent
      // ranges, but never silently drops a selected range).
      double? min;
      double? max;
      bool unbounded = false;
      for (final p in filter.selectedPrices) {
        switch (p) {
          case PriceRange.high:
            min = min == null ? 1000 : (min < 1000 ? min : 1000);
            unbounded = true;
            break;
          case PriceRange.medium:
            min = min == null ? 500 : (min < 500 ? min : 500);
            if (!unbounded) max = max == null ? 999 : (max > 999 ? max : 999);
            break;
          case PriceRange.low:
            min = min == null ? 0 : (min < 0 ? min : 0);
            if (!unbounded) max = max == null ? 499 : (max > 499 ? max : 499);
            break;
        }
      }
      if (min != null) query['minPrice'] = min;
      if (!unbounded && max != null) query['maxPrice'] = max;
    }

    if (filter.selectedDiscounts.isNotEmpty) {
      // Each option means "up to X% off" — the backend takes a single
      // ceiling, so the most permissive (largest) selection covers the
      // union of everything the user checked.
      int maxDiscount = 0;
      for (final d in filter.selectedDiscounts) {
        final value = switch (d) {
          DiscountRange.upTo10 => 10,
          DiscountRange.upTo20 => 20,
          DiscountRange.upTo50 => 50,
        };
        if (value > maxDiscount) maxDiscount = value;
      }
      query['maxDiscount'] = maxDiscount;
    }

    return query;
  }

  List<BookEntity> _books(Map<String, dynamic> body) {
    final rawList = body['data']?['books'];
    if (rawList is! List) {
      return const <BookEntity>[];
    }

    final books = <BookEntity>[];
    for (final rawItem in rawList) {
      books.add(BookEntity.fromJson(rawItem as Map<String, dynamic>));
    }
    return books;
  }

  @override
  Future<SearchPage> search(
    String query,
    FilterState filter, {
    int page = 1,
  }) async {
    final params = _filterQuery(filter);
    params['page'] = page;
    params['limit'] = 20;
    if (query.trim().isNotEmpty) {
      params['search'] = query.trim();
      params['q'] = query.trim(); // also saved to recent-search history
    }
    final body = await _client.get('/search', query: params);
    final data = body['data'] as Map<String, dynamic>?;
    final pagination = data?['pagination'] as Map<String, dynamic>?;
    return SearchPage(
      books: _books(body),
      page: (pagination?['page'] as num?)?.toInt() ?? page,
      totalPages: (pagination?['totalPages'] as num?)?.toInt() ?? page,
    );
  }

  @override
  Future<List<BookEntity>> getPopular(FilterState filter) async {
    final body = await _client.get(
      '/search/popular',
      query: _filterQuery(filter),
    );
    return _books(body);
  }

  @override
  Future<List<BookEntity>> getNewReleased(FilterState filter) async {
    final body = await _client.get(
      '/search/new-released',
      query: _filterQuery(filter),
    );
    return _books(body);
  }

  @override
  Future<List<BookEntity>> getOnSale(FilterState filter) async {
    final body = await _client.get(
      '/search/on-sale',
      query: _filterQuery(filter),
    );
    return _books(body);
  }

  @override
  Future<List<BookEntity>> getHighlyRecommended() async {
    final body = await _client.get('/search/highly-recommended');
    final rawList = body['data']?['books'];
    if (rawList is! List) {
      return const <BookEntity>[];
    }

    final books = <BookEntity>[];
    for (final rawItem in rawList) {
      books.add(BookEntity.fromJson(rawItem as Map<String, dynamic>));
    }
    return books;
  }

  @override
  Future<List<String>> getRecentSearches() async {
    final body = await _client.get('/search/recent');
    final list = (body['data']?['queries'] as List?) ?? [];
    return list.map((q) => q.toString()).toList();
  }

  @override
  Future<void> removeRecentSearch(String query) async {
    await _client.delete('/search/recent/${Uri.encodeComponent(query)}');
  }

  @override
  Future<void> clearRecentSearches() async {
    await _client.delete('/search/recent');
  }
}
