import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/features/orders/domain/entities/order_item.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;

    switch (status) {
      case OrderStatus.processing:
        bgColor = const Color(0xFFFFEBD6);
        textColor = const Color(0xFFE8602C);
        break;
      case OrderStatus.delivered:
        bgColor = const Color(0xFFD4F4E2);
        textColor = const Color(0xFF1E8449);
        break;
      case OrderStatus.cancelled:
        bgColor = const Color(0xFFFFE0E0);
        textColor = const Color(0xFFC0392B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.lato(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
