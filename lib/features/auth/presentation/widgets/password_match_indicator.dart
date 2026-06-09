import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordMatchIndicator extends StatelessWidget {
  final bool isMatch;
  final bool isVisible;

  const PasswordMatchIndicator({
    super.key,
    required this.isMatch,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(
          isMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 15,
          color: isMatch ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 6),
        Text(
          isMatch ? 'Password Matched' : 'Passwords do not match',
          style: GoogleFonts.lato(
            fontSize: 12,
            color: isMatch ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
