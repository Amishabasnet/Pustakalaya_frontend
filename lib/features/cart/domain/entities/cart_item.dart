import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

class CartItem {
  final BookEntity book;
  final int quantity;

  const CartItem({required this.book, required this.quantity});

  CartItem copyWith({int? quantity}) =>
      CartItem(book: book, quantity: quantity ?? this.quantity);

  double get subtotal => book.price * quantity;
}
