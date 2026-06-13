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
  });

  double get total => price * quantity;
}
