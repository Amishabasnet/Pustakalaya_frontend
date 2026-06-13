import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';

class OrderTabBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const OrderTabBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  static const _tabs = ['All', 'Processing', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_tabs.length, (i) {
        final selected = i == activeIndex;
        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? AppColors.textDark
                          : AppColors.textMedium,
                    ),
                    child: Text(_tabs[i], textAlign: TextAlign.center),
                  ),
                ),
                // Active underline indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  height: 2.5,
                  width: selected ? 48 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
