enum OrderStatus { processing, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isProcessing => this == OrderStatus.processing;
  bool get isDelivered => this == OrderStatus.delivered;
  bool get isCancelled => this == OrderStatus.cancelled;

  /// Maps the backend's finer-grained lifecycle string onto the 3 states
  /// the UI understands.
  static OrderStatus fromRaw(String raw) {
    switch (raw) {
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default: // placed, confirmed, processing, shipped
        return OrderStatus.processing;
    }
  }
}

class OrderItem {
  final String id;
  final String orderNumber;
  final String bookTitle;
  final String bookAuthor;
  final String coverColor;
  final double price;
  final int quantity;
  final OrderStatus status;
  final DateTime orderedAt;
  final DateTime? deliveredAt;

  /// How many distinct books this order contains — the card/detail UI
  /// shows the first book, this lets it hint at "+2 more".
  final int itemsCount;

  /// The exact backend status string (placed/confirmed/processing/shipped/
  /// delivered/cancelled) — only placed & confirmed orders can be cancelled.
  final String rawStatus;
  final double total;
  final String deliveryAddressLine;

  const OrderItem({
    required this.id,
    required this.orderNumber,
    required this.bookTitle,
    required this.bookAuthor,
    required this.coverColor,
    required this.price,
    required this.quantity,
    required this.status,
    required this.orderedAt,
    this.deliveredAt,
    this.itemsCount = 1,
    this.rawStatus = '',
    double? total,
    this.deliveryAddressLine = '',
  }) : total = total ?? price * quantity;

  bool get isCancellable => rawStatus == 'placed' || rawStatus == 'confirmed';
}
