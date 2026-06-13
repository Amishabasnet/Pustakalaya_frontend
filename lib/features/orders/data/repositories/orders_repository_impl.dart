import 'package:pustakalaya/features/orders/domain/entities/order_item.dart';
import 'package:pustakalaya/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  @override
  Future<List<OrderItem>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return [
      OrderItem(
        id: 'o1',
        orderNumber: 'FS-11111',
        bookTitle: 'The Alchemist',
        bookAuthor: 'Paulo Coelho',
        coverColor: '#C0392B',
        price: 800,
        quantity: 1,
        status: OrderStatus.processing,
        orderedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      OrderItem(
        id: 'o2',
        orderNumber: 'FS-11122',
        bookTitle: 'Atomic Habits',
        bookAuthor: 'James Clear',
        coverColor: '#2E86AB',
        price: 800,
        quantity: 1,
        status: OrderStatus.processing,
        orderedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      OrderItem(
        id: 'o3',
        orderNumber: 'FS-11132',
        bookTitle: 'Ikigai',
        bookAuthor: 'Hector Garcia Puigcerver',
        coverColor: '#D6E8F0',
        price: 958,
        quantity: 1,
        status: OrderStatus.delivered,
        orderedAt: DateTime.now().subtract(const Duration(days: 14)),
        deliveredAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      OrderItem(
        id: 'o4',
        orderNumber: 'FS-11431',
        bookTitle: 'Harry Potter',
        bookAuthor: 'J.K. Rowling',
        coverColor: '#1A2A6C',
        price: 800,
        quantity: 1,
        status: OrderStatus.delivered,
        orderedAt: DateTime.now().subtract(const Duration(days: 30)),
        deliveredAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
    ];
  }
}
