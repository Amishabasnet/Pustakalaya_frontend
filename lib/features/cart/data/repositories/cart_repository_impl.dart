import 'package:pustakalaya/core/network/api_client.dart';
import 'package:pustakalaya/features/cart/domain/entities/cart_item.dart';
import 'package:pustakalaya/features/cart/domain/repositories/cart_repository.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

class CartRepositoryImpl implements CartRepository {
  final ApiClient _client = ApiClient.instance;

  List<CartItem> _parse(Map<String, dynamic> body) {
    final items = (body['data']?['items'] as List?) ?? [];
    return items.map((raw) {
      final map = raw as Map<String, dynamic>;
      final bookJson = map['book'] as Map<String, dynamic>?;
      final book = bookJson != null
          ? BookEntity.fromJson(bookJson)
          : BookEntity(
              id: (map['book'] ?? '').toString(),
              title: 'Unknown book',
              author: '',
              price: (map['priceAtAdd'] as num?)?.toDouble() ?? 0,
              rating: 0,
              reviewCount: 0,
              genre: '',
              coverColor: '#3B5998',
            );
      return CartItem(
        book: book,
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      );
    }).toList();
  }

  @override
  Future<List<CartItem>> getCart() async {
    final body = await _client.get('/cart');
    return _parse(body);
  }

  @override
  Future<List<CartItem>> addToCart(BookEntity book, {int quantity = 1}) async {
    await _client.post('/cart/${book.id}', body: {'quantity': quantity});
    return getCart();
  }

  @override
  Future<List<CartItem>> updateQuantity(String bookId, int quantity) async {
    await _client.patch('/cart/$bookId', body: {'quantity': quantity});
    return getCart();
  }

  @override
  Future<List<CartItem>> removeItem(String bookId) async {
    await _client.delete('/cart/$bookId');
    return getCart();
  }

  @override
  Future<void> clearCart() async {
    await _client.delete('/cart');
  }
}
