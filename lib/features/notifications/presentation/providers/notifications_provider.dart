import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/core/services/local_notification_service.dart';
import 'package:pustakalaya/features/notifications/domain/entities/app_notification.dart';

const _notificationPool = [
  (
    title: 'Order Confirmed',
    body: 'Your order #PB1024 has been confirmed.',
    type: NotificationType.orderConfirmed,
  ),
  (
    title: 'Flash Sale 🔥',
    body: 'Up to 50% OFF on selected books. Limited time!',
    type: NotificationType.flashSale,
  ),
  (
    title: 'Wishlist Item on Sale',
    body: '"The Alchemist" is now 25% OFF.',
    type: NotificationType.wishlistSale,
  ),
  (
    title: 'Order Delivered',
    body: 'Your order #PB1024 was delivered successfully.',
    type: NotificationType.orderDelivered,
  ),
  (
    title: 'New Arrival',
    body: 'New books added in Technology category.',
    type: NotificationType.newArrival,
  ),
  (
    title: 'Price Drop Alert',
    body: '"Atomic Habits" price dropped to NRs. 499!',
    type: NotificationType.flashSale,
  ),
  (
    title: 'Your Review Posted',
    body: 'Your review for "Sapiens" is now live.',
    type: NotificationType.newArrival,
  ),
];

class NotificationsNotifier
    extends StateNotifier<List<AppNotification>> {
  Timer? _timer;
  int _poolIndex = 0;
  int _idCounter = 100;

  NotificationsNotifier() : super(_initialNotifications()) {
    _startPeriodicNotifications();
  }

  // Pre-seed with design-matching notifications
  static List<AppNotification> _initialNotifications() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return [
      AppNotification(
        id: '1',
        title: 'Order Confirmed',
        body: 'Your order #PB1024 has been confirmed.',
        timestamp: now.subtract(const Duration(minutes: 2)),
        type: NotificationType.orderConfirmed,
      ),
      AppNotification(
        id: '2',
        title: 'Flash Sale',
        body: 'Up to 50% OFF on selected books.',
        timestamp: now.subtract(const Duration(hours: 1)),
        type: NotificationType.flashSale,
      ),
      AppNotification(
        id: '3',
        title: 'Wishlist Item on Sale',
        body: '"The Alchemist" is now 25% OFF.',
        timestamp: now.subtract(const Duration(hours: 3)),
        type: NotificationType.wishlistSale,
      ),
      AppNotification(
        id: '4',
        title: 'Order Delivered',
        body: 'Your order #PB1024 was delivered successfully.',
        timestamp: yesterday.copyWith(hour: 16, minute: 30),
        type: NotificationType.orderDelivered,
      ),
      AppNotification(
        id: '5',
        title: 'New Arrival',
        body: 'New books added in Technology category.',
        timestamp: yesterday.copyWith(hour: 9, minute: 0),
        type: NotificationType.newArrival,
      ),
    ];
  }

  void _startPeriodicNotifications() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fireNext();
    });
  }

  Future<void> _fireNext() async {
    final template = _notificationPool[_poolIndex % _notificationPool.length];
    _poolIndex++;
    _idCounter++;

    // Push system notification
    await LocalNotificationService.instance.show(
      id: _idCounter,
      title: template.title,
      body: template.body,
    );

    // Add to in-app list
    final newNotif = AppNotification(
      id: '$_idCounter',
      title: template.title,
      body: template.body,
      timestamp: DateTime.now(),
      type: template.type,
    );
    state = [newNotif, ...state];
  }

  Future<void> sendNow({
    required String title,
    required String body,
    required NotificationType type,
  }) async {
    _idCounter++;
    await LocalNotificationService.instance.show(
      id: _idCounter,
      title: title,
      body: body,
    );
    state = [
      AppNotification(
        id: '$_idCounter',
        title: title,
        body: body,
        timestamp: DateTime.now(),
        type: type,
      ),
      ...state,
    ];
  }

  void markRead(String id) {
    state = state
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
  }

  void markAllRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void delete(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  (ref) => NotificationsNotifier(),
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});

final groupedNotificationsProvider =
    Provider<Map<String, List<AppNotification>>>((ref) {
  final notifs = ref.watch(notificationsProvider);
  final grouped = <String, List<AppNotification>>{};
  for (final n in notifs) {
    grouped.putIfAbsent(n.groupKey, () => []).add(n);
  }
  return grouped;
});
