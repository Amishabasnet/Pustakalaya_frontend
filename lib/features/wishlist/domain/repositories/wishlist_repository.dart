import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/wishlist/domain/entities/wishlist_item.dart';

abstract class WishlistRepository {
  Future<List<WishlistItem>> getWishlist();

  /// Toggles the book on/off the wishlist and returns whether it's now
  /// wishlisted.
  Future<bool> toggle(BookEntity book);
}
