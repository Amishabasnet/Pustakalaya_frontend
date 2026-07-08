import 'package:pustakalaya/features/filter/domain/entities/filter_state.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

class SearchPage {
  final List<BookEntity> books;
  final int page;
  final int totalPages;

  const SearchPage({
    required this.books,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}

abstract class SearchRepository {
  Future<SearchPage> search(String query, FilterState filter, {int page = 1});
  Future<List<BookEntity>> getPopular(FilterState filter);
  Future<List<BookEntity>> getNewReleased(FilterState filter);
  Future<List<BookEntity>> getOnSale(FilterState filter);
  Future<List<BookEntity>> getHighlyRecommended();

  Future<List<String>> getRecentSearches();
  Future<void> removeRecentSearch(String query);
  Future<void> clearRecentSearches();
}
