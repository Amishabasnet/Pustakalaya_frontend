import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/book_detail/data/repositories/book_detail_repository_detail.dart';
import 'package:pustakalaya/features/book_detail/domain/entities/book_detail.dart';
import 'package:pustakalaya/features/book_detail/domain/repositories/book_detail_repository.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

final bookDetailRepositoryProvider = Provider<BookDetailRepository>(
  (ref) => BookDetailRepositoryImpl(),
);

/// Set by whichever screen the user taps a book card on (home, search,
/// wishlist, cart, etc.) — [bookDetailProvider] reacts to it and fetches
/// the full detail (description, live stock, recent reviews) from the API.
final selectedBookProvider = StateProvider<BookEntity?>((ref) => null);

final bookDetailProvider = FutureProvider.autoDispose<BookDetail?>((ref) async {
  final book = ref.watch(selectedBookProvider);
  if (book == null) return null;
  final repo = ref.watch(bookDetailRepositoryProvider);
  return repo.getBookDetail(book.id);
});

final bookQuantityProvider = StateProvider.autoDispose<int>((ref) => 1);

final accordionProvider = StateProvider.autoDispose<Map<int, bool>>(
  (ref) => {0: true, 1: false, 2: true},
);
