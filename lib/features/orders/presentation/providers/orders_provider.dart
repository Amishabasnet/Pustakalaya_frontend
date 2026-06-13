import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:pustakalaya/features/orders/domain/entities/order_item.dart';
import 'package:pustakalaya/features/orders/domain/repositories/orders_repository.dart';


final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepositoryImpl(),
);

final ordersProvider = FutureProvider<List<OrderItem>>((ref) {
  return ref.watch(ordersRepositoryProvider).getOrders();
});

final orderTabProvider = StateProvider<int>((ref) => 0);

final filteredOrdersProvider = Provider<AsyncValue<List<OrderItem>>>((ref) {
  final tab = ref.watch(orderTabProvider);
  final ordersAsync = ref.watch(ordersProvider);

  return ordersAsync.whenData((orders) {
    switch (tab) {
      case 1:
        return orders
            .where((o) => o.status == OrderStatus.processing)
            .toList();
      case 2:
        return orders
            .where((o) => o.status == OrderStatus.delivered)
            .toList();
      default:
        return orders;
    }
  });
});
