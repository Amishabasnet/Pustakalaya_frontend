import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:pustakalaya/features/notifications/presentation/widgets/notification_tile.dart';


class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedNotificationsProvider);
    final unread = ref.watch(unreadCountProvider);
    final screenW = MediaQuery.of(context).size.width;
    final hPad = screenW > 600 ? 32.0 : 16.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (unread > 0) {
      }
    });

    final groupOrder = ['Today', 'Yesterday'];
    final otherKeys = grouped.keys
        .where((k) => k != 'Today' && k != 'Yesterday')
        .toList()
      ..sort((a, b) => b.compareTo(a));
    final allKeys = [
      ...groupOrder.where((k) => grouped.containsKey(k)),
      ...otherKeys,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: hPad, vertical: 12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.of(context).maybePop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        // Title
                        Text(
                          'Notifications',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        // Mark all read button
                        if (unread > 0)
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => ref
                                  .read(notificationsProvider.notifier)
                                  .markAllRead(),
                              child: Text(
                                'Mark all read',
                                style: GoogleFonts.lato(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1),
                ],
              ),
            ),

            Expanded(
              child: grouped.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                          top: 12, bottom: 24),
                      itemCount: _itemCount(allKeys, grouped),
                      itemBuilder: (context, index) {
                        // Flatten groups into section headers + tiles
                        int cursor = 0;
                        for (final key in allKeys) {
                          final items = grouped[key]!;
                          // Section header
                          if (index == cursor) {
                            return _SectionHeader(label: key);
                          }
                          cursor++;
                          // Tiles
                          for (int i = 0; i < items.length; i++) {
                            if (index == cursor) {
                              return NotificationTile(
                                  notification: items[i]);
                            }
                            cursor++;
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  int _itemCount(
      List<String> keys, Map<String, List<dynamic>> grouped) {
    int count = 0;
    for (final key in keys) {
      count += 1 + (grouped[key]?.length ?? 0); // header + tiles
    }
    return count;
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textMedium,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 44,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No notifications yet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you about orders,\noffers and new arrivals.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
