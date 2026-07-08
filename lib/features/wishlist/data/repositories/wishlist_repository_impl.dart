import 'package:pustakalaya/core/network/api_client.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:pustakalaya/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<List<WishlistItem>> getWishlist() async {
    final body = await _client.get('/wishlist');
    final books = (body['data']?['books'] as List?) ?? [];
    return books.map((raw) {
      final map = raw as Map<String, dynamic>;
      final bookJson = map['book'] as Map<String, dynamic>?;
      final book = bookJson != null
          ? BookEntity.fromJson(bookJson)
          : const BookEntity(
              id: '',
              title: 'Unknown book',
              author: '',
              price: 0,
              rating: 0,
              reviewCount: 0,
              genre: '',
              coverColor: '#3B5998',
            );
      final addedAtStr = map['addedAt'] as String?;
      return WishlistItem(
        book: book,
        addedAt: addedAtStr != null
            ? DateTime.tryParse(addedAtStr) ?? DateTime.now()
            : DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<bool> toggle(BookEntity book) async {
    final body = await _client.post('/wishlist/${book.id}');
    return body['data']?['wishlisted'] as bool? ?? false;
  }
}
