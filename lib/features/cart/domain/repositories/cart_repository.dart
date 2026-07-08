import 'package:pustakalaya/features/cart/domain/entities/cart_item.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCart();
  Future<List<CartItem>> addToCart(BookEntity book, {int quantity = 1});
  Future<List<CartItem>> updateQuantity(String bookId, int quantity);
  Future<List<CartItem>> removeItem(String bookId);
  Future<void> clearCart();
}
