import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifiedBadge extends StatelessWidget {
  final bool small;
  const VerifiedBadge({super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.verified_rounded,
          size: small ? 11 : 13,
          color: const Color(0xFF27AE60),
        ),
        const SizedBox(width: 3),
        Text(
          'Verified',
          style: GoogleFonts.lato(
            fontSize: small ? 9 : 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF27AE60),
          ),
        ),
      ],
    );
  }
}
