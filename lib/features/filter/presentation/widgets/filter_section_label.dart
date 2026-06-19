import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';

class FilterSectionLabel extends StatelessWidget {
  final String label;

  const FilterSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
