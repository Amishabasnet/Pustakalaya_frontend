import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/order_item.dart';

/// Text-only status label (no background fill) — matches screenshot exactly
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    switch (status) {
      case OrderStatus.processing:
        textColor = const Color(0xFFE8602C); // orange
        break;
      case OrderStatus.delivered:
        textColor = const Color(0xFF27AE60); // green
        break;
      case OrderStatus.cancelled:
        textColor = const Color(0xFFC0392B); // red
        break;
    }

    return Text(
      status.label,
      style: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}
