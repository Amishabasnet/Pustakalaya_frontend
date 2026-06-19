enum NotificationType {
  orderConfirmed,
  flashSale,
  wishlistSale,
  orderDelivered,
  newArrival,
}

extension NotificationTypeX on NotificationType {
  String get emoji {
    switch (this) {
      case NotificationType.orderConfirmed:
        return '📦';
      case NotificationType.flashSale:
        return '🔥';
      case NotificationType.wishlistSale:
        return '⭐';
      case NotificationType.orderDelivered:
        return '🚚';
      case NotificationType.newArrival:
        return '📚';
    }
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    body: body,
    timestamp: timestamp,
    type: type,
    isRead: isRead ?? this.isRead,
  );

  String get groupKey {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notifDay = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (notifDay == today) return 'Today';
    if (notifDay == yesterday) return 'Yesterday';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
