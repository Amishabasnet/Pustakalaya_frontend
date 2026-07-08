import 'package:pustakalaya/core/network/api_client.dart';
import 'package:pustakalaya/features/orders/domain/entities/order_item.dart';
import 'package:pustakalaya/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final ApiClient _client = ApiClient.instance;

  String _colorFor(String seed) {
    final hash = seed.hashCode;
    const palette = [
      '3B5998',
      'C0392B',
      '2E86AB',
      '1A6B3C',
      '5D3FD3',
      'E8602C',
      '8E44AD',
      '16A085',
      'D35400',
      '2C3E50',
    ];
    return '#${palette[hash.abs() % palette.length]}';
  }

  OrderItem _fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?) ?? [];
    final first = items.isNotEmpty ? items.first as Map<String, dynamic> : null;
    final address = json['deliveryAddress'] as Map<String, dynamic>?;
    final rawStatus = (json['status'] ?? 'placed').toString();
    final createdAtStr = json['createdAt'] as String?;

    return OrderItem(
      id: (json['orderId'] ?? json['_id'] ?? '').toString(),
      orderNumber: (json['orderId'] ?? '').toString(),
      bookTitle: (first?['title'] ?? 'Order').toString(),
      bookAuthor: (first?['author'] ?? '').toString(),
      coverColor: _colorFor(
        (first?['title'] ?? json['orderId'] ?? '').toString(),
      ),
      price: (first?['price'] as num?)?.toDouble() ?? 0,
      quantity: (first?['quantity'] as num?)?.toInt() ?? 1,
      status: OrderStatusX.fromRaw(rawStatus),
      orderedAt: createdAtStr != null
          ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
          : DateTime.now(),
      deliveredAt: rawStatus == 'delivered' && createdAtStr != null
          ? DateTime.tryParse(createdAtStr)
          : null,
      itemsCount: items.length,
      rawStatus: rawStatus,
      total: (json['total'] as num?)?.toDouble(),
      deliveryAddressLine: address == null
          ? ''
          : '${address['street'] ?? ''}, ${address['city'] ?? ''}',
    );
  }

  @override
  Future<OrdersPage> getOrders({
    int page = 1,
    int limit = 10,
    String? statusFilter,
  }) async {
    final body = await _client.get(
      '/checkout',
      query: {
        'page': page,
        'limit': limit,
        if (statusFilter != null) 'statusFilter': statusFilter,
      },
    );
    final data = body['data'] as Map<String, dynamic>;
    final list = (data['orders'] as List?) ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>?;
    return OrdersPage(
      orders: list.map((o) => _fromJson(o as Map<String, dynamic>)).toList(),
      page: (pagination?['page'] as num?)?.toInt() ?? page,
      totalPages: (pagination?['totalPages'] as num?)?.toInt() ?? page,
    );
  }

  @override
  Future<OrderItem> getOrder(String orderId) async {
    final body = await _client.get('/checkout/$orderId');
    return _fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<CheckoutSummary> getCheckoutSummary() async {
    final body = await _client.get('/checkout/summary');
    final data = body['data'] as Map<String, dynamic>;
    final options = (data['deliveryOptions'] as List? ?? []).map((o) {
      final m = o as Map<String, dynamic>;
      return DeliveryOptionInfo(
        key: (m['key'] ?? '').toString(),
        label: (m['label'] ?? '').toString(),
        charge: (m['charge'] as num?)?.toDouble() ?? 0,
        estimate: (m['estimate'] ?? '').toString(),
      );
    }).toList();

    return CheckoutSummary(
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryOptions: options,
      paymentMethods: (data['paymentMethods'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  Future<PlacedOrder> placeOrder({
    required DeliveryAddress deliveryAddress,
    required String deliveryOption,
    required String paymentMethod,
  }) async {
    final body = await _client.post(
      '/checkout/place-order',
      body: {
        'deliveryAddress': deliveryAddress.toJson(),
        'deliveryOption': deliveryOption,
        'paymentMethod': paymentMethod,
      },
    );
    final data = body['data'] as Map<String, dynamic>;
    return PlacedOrder(
      orderId: (data['orderId'] ?? '').toString(),
      total: (data['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: (data['paymentMethod'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      estimatedDelivery: data['estimatedDelivery'] as String?,
    );
  }

  @override
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    await _client.patch(
      '/checkout/$orderId/cancel',
      body: reason != null ? {'reason': reason} : null,
    );
  }
}
