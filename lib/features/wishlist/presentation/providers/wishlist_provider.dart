import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/core/network/api_exception.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:pustakalaya/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:pustakalaya/features/wishlist/domain/repositories/wishlist_repository.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => WishlistRepositoryImpl(),
);

final wishlistErrorProvider = StateProvider<String?>((ref) => null);

class WishlistNotifier extends StateNotifier<List<WishlistItem>> {
  final WishlistRepository _repo;
  final Ref _ref;

  WishlistNotifier(this._repo, this._ref) : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      state = await _repo.getWishlist();
      _ref.read(wishlistErrorProvider.notifier).state = null;
    } on ApiException catch (e) {
      _ref.read(wishlistErrorProvider.notifier).state = e.message;
    }
  }

  bool isWishlisted(String bookId) =>
      state.any((item) => item.book.id == bookId);

  /// Optimistically flips membership, then reconciles with the server.
  Future<void> toggle(BookEntity book) async {
    final wasWishlisted = isWishlisted(book.id);
    if (wasWishlisted) {
      state = state.where((item) => item.book.id != book.id).toList();
    } else {
      state = [
        ...state,
        WishlistItem(book: book, addedAt: DateTime.now()),
      ];
    }

    try {
      await _repo.toggle(book);
      _ref.read(wishlistErrorProvider.notifier).state = null;
    } on ApiException catch (e) {
      // Roll back the optimistic update on failure.
      await refresh();
      _ref.read(wishlistErrorProvider.notifier).state = e.message;
    }
  }

  Future<void> remove(String bookId) async {
    final matches = state.where((i) => i.book.id == bookId);
    if (matches.isEmpty) return;
    await toggle(matches.first.book);
  }

  /// Personal star rating kept locally — the backend has no per-wishlist
  /// rating field (ratings live on Reviews, tied to a written review).
  void setRating(String bookId, int rating) {
    state = state
        .map((item) =>
            item.book.id == bookId ? item.copyWith(userRating: rating) : item)
        .toList();
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<WishlistItem>>(
  (ref) => WishlistNotifier(ref.watch(wishlistRepositoryProvider), ref),
);

// Search query for wishlist
final wishlistSearchProvider = StateProvider<String>((ref) => '');

// Filtered wishlist
final filteredWishlistProvider = Provider<List<WishlistItem>>((ref) {
  final items = ref.watch(wishlistProvider);
  final query = ref.watch(wishlistSearchProvider).toLowerCase();
  if (query.isEmpty) return items;
  return items
      .where((i) =>
          i.book.title.toLowerCase().contains(query) ||
          i.book.author.toLowerCase().contains(query))
      .toList();
});
