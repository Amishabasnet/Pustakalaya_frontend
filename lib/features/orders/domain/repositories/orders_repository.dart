import 'package:pustakalaya/features/orders/domain/entities/order_item.dart';

class DeliveryAddress {
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String province;

  const DeliveryAddress({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    this.province = '',
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phone': phone,
    'street': street,
    'city': city,
    if (province.isNotEmpty) 'province': province,
  };
}

class DeliveryOptionInfo {
  final String key;
  final String label;
  final double charge;
  final String estimate;

  const DeliveryOptionInfo({
    required this.key,
    required this.label,
    required this.charge,
    required this.estimate,
  });
}

class CheckoutSummary {
  final double subtotal;
  final List<DeliveryOptionInfo> deliveryOptions;
  final List<String> paymentMethods;

  const CheckoutSummary({
    required this.subtotal,
    required this.deliveryOptions,
    required this.paymentMethods,
  });

  double chargeFor(String optionKey) => deliveryOptions
      .firstWhere(
        (o) => o.key == optionKey,
        orElse: () => const DeliveryOptionInfo(
          key: 'standard',
          label: 'Standard',
          charge: 120,
          estimate: '',
        ),
      )
      .charge;
}

class PlacedOrder {
  final String orderId;
  final double total;
  final String paymentMethod;
  final String status;
  final String? estimatedDelivery;

  const PlacedOrder({
    required this.orderId,
    required this.total,
    required this.paymentMethod,
    required this.status,
    this.estimatedDelivery,
  });
}

class OrdersPage {
  final List<OrderItem> orders;
  final int page;
  final int totalPages;

  const OrdersPage({
    required this.orders,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}

abstract class OrdersRepository {
  Future<OrdersPage> getOrders({
    int page = 1,
    int limit = 10,
    String? statusFilter,
  });
  Future<OrderItem> getOrder(String orderId);
  Future<CheckoutSummary> getCheckoutSummary();
  Future<PlacedOrder> placeOrder({
    required DeliveryAddress deliveryAddress,
    required String deliveryOption,
    required String paymentMethod,
  });
  Future<void> cancelOrder(String orderId, {String? reason});
}
