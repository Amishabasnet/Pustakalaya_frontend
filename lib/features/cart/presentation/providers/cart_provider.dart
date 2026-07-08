import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/core/network/api_exception.dart';
import 'package:pustakalaya/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:pustakalaya/features/cart/domain/entities/cart_item.dart';
import 'package:pustakalaya/features/cart/domain/repositories/cart_repository.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepositoryImpl(),
);

/// Non-null while a cart mutation is in flight or just failed, so the UI can
/// show a spinner / error banner without changing the `List<CartItem>` state
/// shape that every screen already depends on.
final cartLoadingProvider = StateProvider<bool>((ref) => false);
final cartErrorProvider = StateProvider<String?>((ref) => null);

class CartNotifier extends StateNotifier<List<CartItem>> {
  final CartRepository _repo;

  CartNotifier(this._repo, this._ref) : super([]) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    _ref.read(cartLoadingProvider.notifier).state = true;
    try {
      state = await _repo.getCart();
      _ref.read(cartErrorProvider.notifier).state = null;
    } on ApiException catch (e) {
      _ref.read(cartErrorProvider.notifier).state = e.message;
    } finally {
      _ref.read(cartLoadingProvider.notifier).state = false;
    }
  }

  Future<void> add(BookEntity book, {int quantity = 1}) async {
    _ref.read(cartLoadingProvider.notifier).state = true;
    try {
      state = await _repo.addToCart(book, quantity: quantity);
      _ref.read(cartErrorProvider.notifier).state = null;
    } on ApiException catch (e) {
      _ref.read(cartErrorProvider.notifier).state = e.message;
    } finally {
      _ref.read(cartLoadingProvider.notifier).state = false;
    }
  }

  Future<void> increment(String bookId) async {
    final item = state.firstWhere((i) => i.book.id == bookId);
    await _setQuantity(bookId, item.quantity + 1);
  }

  Future<void> decrement(String bookId) async {
    final item = state.firstWhere((i) => i.book.id == bookId);
    if (item.quantity <= 1) {
      await remove(bookId);
    } else {
      await _setQuantity(bookId, item.quantity - 1);
    }
  }

  Future<void> _setQuantity(String bookId, int quantity) async {
    try {
      state = await _repo.updateQuantity(bookId, quantity);
      _ref.read(cartErrorProvider.notifier).state = null;
    } on ApiException catch (e) {
      _ref.read(cartErrorProvider.notifier).state = e.message;
    }
  }

  Future<void> remove(String bookId) async {
    try {
      state = await _repo.removeItem(bookId);
      _ref.read(cartErrorProvider.notifier).state = null;
    } on ApiException catch (e) {
      _ref.read(cartErrorProvider.notifier).state = e.message;
    }
  }

  Future<void> clear() async {
    try {
      await _repo.clearCart();
      state = [];
      _ref.read(cartErrorProvider.notifier).state = null;
    } on ApiException catch (e) {
      _ref.read(cartErrorProvider.notifier).state = e.message;
    }
  }

  double get total => state.fold(0, (sum, item) => sum + item.subtotal);

  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(ref.watch(cartRepositoryProvider), ref),
);

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});
