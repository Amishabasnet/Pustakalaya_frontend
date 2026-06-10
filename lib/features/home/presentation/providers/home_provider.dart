import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/home/data/repositories/home_repository_impl.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/home/domain/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(),
);

final featuredBooksProvider = FutureProvider<List<BookEntity>>((ref) {
  return ref.watch(homeRepositoryProvider).getFeaturedBooks();
});

final recentlyAddedProvider = FutureProvider<List<BookEntity>>((ref) {
  return ref.watch(homeRepositoryProvider).getRecentlyAddedBooks();
});

final genresProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(homeRepositoryProvider).getGenres();
});

final selectedGenreProvider = StateProvider<String>((ref) => 'All');

// Wishlist toggle state for heart icons on home screen
final homeWishlistIdsProvider = StateProvider<Set<String>>((ref) => {});
