import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/core/network/api_exception.dart';
import 'package:pustakalaya/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:pustakalaya/features/orders/domain/entities/order_item.dart';
import 'package:pustakalaya/features/orders/domain/repositories/orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepositoryImpl(),
);

const int _pageSize = 10;

/// 0 = all orders, 1 = processing, 2 = delivered — matches the tab bar and
/// is sent straight to the server as `statusFilter` so pagination and
/// status filtering both happen on the backend.
final orderTabProvider = StateProvider<int>((ref) => 0);

String? _statusFilterFor(int tab) => switch (tab) {
  1 => 'processing',
  2 => 'delivered',
  _ => null,
};

class OrdersListState {
  final List<OrderItem> orders;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  const OrdersListState({
    this.orders = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
  });

  OrdersListState copyWith({
    List<OrderItem>? orders,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
  }) => OrdersListState(
    orders: orders ?? this.orders,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    page: page ?? this.page,
    error: error,
  );
}

/// One paginated, infinite-scrolling order list per tab.
class OrdersListNotifier extends StateNotifier<OrdersListState> {
  final OrdersRepository _repo;
  final String? _statusFilter;

  OrdersListNotifier(this._repo, this._statusFilter)
    : super(const OrdersListState()) {
    loadMore();
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final nextPage = state.page + 1;
      final result = await _repo.getOrders(
        page: nextPage,
        limit: _pageSize,
        statusFilter: _statusFilter,
      );
      state = state.copyWith(
        orders: [...state.orders, ...result.orders],
        page: result.page,
        hasMore: result.hasMore,
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.message);
    }
  }

  Future<void> refresh() async {
    state = const OrdersListState();
    await loadMore();
  }
}

final ordersListProvider = StateNotifierProvider.autoDispose
    .family<OrdersListNotifier, OrdersListState, int>((ref, tab) {
      return OrdersListNotifier(
        ref.watch(ordersRepositoryProvider),
        _statusFilterFor(tab),
      );
    });

/// Cancels an order on the server, then refreshes every open tab's list.
Future<void> cancelOrderAndRefresh(WidgetRef ref, String orderId) async {
  await ref.read(ordersRepositoryProvider).cancelOrder(orderId);
  for (var tab = 0; tab < 3; tab++) {
    ref.invalidate(ordersListProvider(tab));
  }
}
