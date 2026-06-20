import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/orders/domain/entities/order_item.dart';
import 'package:pustakalaya/features/orders/presentation/widgets/order_status_bar.dart';

class OrderCard extends StatelessWidget {
  final OrderItem order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  Color get _coverColor {
    final hex = order.coverColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  bool get _isDarkCover {
    final c = _coverColor;
    final luminance = (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255;
    return luminance < 0.55;
  }

  @override
  Widget build(BuildContext context) {
    final textOnCover = _isDarkCover ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 70,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _coverColor,
                      Color.lerp(
                        _coverColor,
                        _isDarkCover ? Colors.black : Colors.white,
                        0.28,
                      )!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Spine
                    Container(width: 6, color: Colors.black.withValues(alpha: 0.18)),
                    Container(width: 6, color: Colors.black.withOpacity(0.18)),
                    // Decorative circle
                    Positioned(
                      top: -14,
                      right: -14,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    // Title on cover
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 6, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.bookTitle,
                            style: GoogleFonts.lato(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: textOnCover,
                              height: 1.25,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            order.bookAuthor,
                            style: GoogleFonts.lato(
                              fontSize: 6.5,
                              color: textOnCover.withValues(alpha: 0.75),
                              color: textOnCover.withOpacity(0.75),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.bookTitle,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order #${order.orderNumber}',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NRs. ${order.total.toStringAsFixed(0)}',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            OrderStatusBadge(status: order.status),
          ],
        ),
      ),
    );
  }
}
