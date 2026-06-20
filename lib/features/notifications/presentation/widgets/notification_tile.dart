import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/notifications/domain/entities/app_notification.dart';
import 'package:pustakalaya/features/notifications/presentation/providers/notifications_provider.dart';


class NotificationTile extends ConsumerWidget {
  final AppNotification notification;

  const NotificationTile({super.key, required this.notification});

  String _relativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    // Yesterday or earlier
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final dayLabel = notification.groupKey == 'Yesterday' ? 'Yesterday' : '';
    return '$dayLabel${dayLabel.isNotEmpty ? ', ' : ''}$h12:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (_) =>
          ref.read(notificationsProvider.notifier).delete(notification.id),
      child: GestureDetector(
        onTap: () =>
            ref.read(notificationsProvider.notifier).markRead(notification.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread ? Colors.white : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(14),
            border: isUnread
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isUnread ? 0.06 : 0.03),
                blurRadius: isUnread ? 10 : 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    notification.type.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _relativeTime(notification.timestamp),
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: AppColors.textMedium,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              if (isUnread)
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 2),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
