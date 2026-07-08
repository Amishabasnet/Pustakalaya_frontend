import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/cart/domain/entities/cart_item.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(_demoItems());

  static List<CartItem> _demoItems() => [
    CartItem(
      book: const BookEntity(
        id: 'f1',
        title: 'Atomic Habits',
        author: 'James Clear',
        price: 599,
        rating: 4.8,
        reviewCount: 2341,
        genre: 'Self-Help',
        coverColor: '#3B5998',
      ),
      quantity: 1,
    ),
    CartItem(
      book: const BookEntity(
        id: 't1',
        title: 'Rich Dad Poor Dad',
        author: 'Robert Kiyosaki',
        price: 399,
        rating: 4.5,
        reviewCount: 3201,
        genre: 'Finance',
        coverColor: '#C0392B',
      ),
      quantity: 2,
    ),
  ];

  void add(BookEntity book, {required int quantity}) {
    final idx = state.indexWhere((i) => i.book.id == book.id);
    if (idx >= 0) {
      final updated = List<CartItem>.from(state);
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + 1);
      state = updated;
    } else {
      state = [...state, CartItem(book: book, quantity: 1)];
    }
  }

  void increment(String bookId) {
    state = state
        .map(
          (i) => i.book.id == bookId ? i.copyWith(quantity: i.quantity + 1) : i,
        )
        .toList();
  }

  void decrement(String bookId) {
    final item = state.firstWhere((i) => i.book.id == bookId);
    if (item.quantity <= 1) {
      remove(bookId);
    } else {
      state = state
          .map(
            (i) =>
                i.book.id == bookId ? i.copyWith(quantity: i.quantity - 1) : i,
          )
          .toList();
    }
  }

  void remove(String bookId) {
    state = state.where((i) => i.book.id != bookId).toList();
  }

  void clear() => state = [];

  double get total => state.fold(0, (sum, item) => sum + item.subtotal);

  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});
