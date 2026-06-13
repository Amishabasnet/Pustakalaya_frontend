import 'package:pustakalaya/features/orders/domain/entities/order_item.dart';

abstract class OrdersRepository {
  Future<List<OrderItem>> getOrders();
}
