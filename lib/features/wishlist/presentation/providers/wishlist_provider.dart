import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/wishlist/domain/entities/wishlist_item.dart';

class WishlistNotifier extends StateNotifier<List<WishlistItem>> {
  WishlistNotifier() : super(_demoItems());

  static List<WishlistItem> _demoItems() => [
        WishlistItem(
          book: const BookEntity(
            id: 'w1',
            title: 'The Subtle Art Of Not Giving A Fu*k',
            author: 'J.K. Rowling',
            price: 880,
            rating: 0,
            reviewCount: 0,
            genre: 'Self-Help',
            coverColor: '#E8602C',
            isVerified: true,
          ),
          addedAt: DateTime.now().subtract(const Duration(days: 1)),
          userRating: 0,
        ),
        WishlistItem(
          book: const BookEntity(
            id: 'w2',
            title: 'Ikigai',
            author: 'Hector Garcia Puigcerver',
            price: 958,
            rating: 0,
            reviewCount: 0,
            genre: 'Self-Help',
            coverColor: '#D6E8F0',
            isVerified: true,
          ),
          addedAt: DateTime.now().subtract(const Duration(days: 4)),
          userRating: 0,
        ),
        WishlistItem(
          book: const BookEntity(
            id: 'w3',
            title: 'The Alchemist',
            author: 'Paulo Coelho',
            price: 650,
            rating: 0,
            reviewCount: 0,
            genre: 'Fiction',
            coverColor: '#C0392B',
            isVerified: true,
          ),
          addedAt: DateTime.now().subtract(const Duration(days: 7)),
          userRating: 0,
        ),
      ];

  bool isWishlisted(String bookId) =>
      state.any((item) => item.book.id == bookId);

  void toggle(BookEntity book) {
    if (isWishlisted(book.id)) {
      state = state.where((item) => item.book.id != book.id).toList();
    } else {
      state = [
        ...state,
        WishlistItem(book: book, addedAt: DateTime.now(), userRating: 0),
      ];
    }
  }

  void remove(String bookId) {
    state = state.where((item) => item.book.id != bookId).toList();
  }

  void setRating(String bookId, int rating) {
    state = state
        .map((item) =>
            item.book.id == bookId ? item.copyWith(userRating: rating) : item)
        .toList();
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<WishlistItem>>(
  (ref) => WishlistNotifier(),
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
