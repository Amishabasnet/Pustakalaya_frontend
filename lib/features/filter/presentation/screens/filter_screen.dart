import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/filter/domain/entities/filter_state.dart';
import 'package:pustakalaya/features/filter/presentation/providers/filter_provider.dart';
import 'package:pustakalaya/features/filter/presentation/widgets/filter_tab_content.dart';


class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({super.key});

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;

  static const _tabs = FilterTab.values;

  @override
  void initState() {
    super.initState();
    final initialTab = ref.read(filterProvider).activeTab;
    _pageController =
        PageController(initialPage: _tabs.indexOf(initialTab));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    ref.read(filterProvider.notifier).setTab(_tabs[index]);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(filterProvider);
    final activeIndex = _tabs.indexOf(filter.activeTab);
    final screenW = MediaQuery.of(context).size.width;
    final hPad = screenW > 600 ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Title row
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Filter',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.of(context).maybePop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withOpacity(0.1),
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
                        // Reset button
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () =>
                                ref.read(filterProvider.notifier).resetAll(),
                            child: Text(
                              'Reset',
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: filter.hasActiveFilters
                                    ? AppColors.primary
                                    : AppColors.textMedium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Color(0xFFEEE5DC), width: 1.2),
                      ),
                    ),
                    child: Row(
                      children: List.generate(_tabs.length, (i) {
                        final selected = i == activeIndex;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _onTabTap(i),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  child: AnimatedDefaultTextStyle(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textMedium,
                                    ),
                                    child: Text(
                                      _tabs[i].label,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                // Active underline
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 220),
                                  height: 2.5,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) =>
                    ref.read(filterProvider.notifier).setTab(_tabs[i]),
                children: _tabs
                    .map((tab) => FilterTabContent(tab: tab))
                    .toList(),
              ),
            ),

            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(hPad, 14, hPad,
                  MediaQuery.of(context).padding.bottom + 14),
              child: Row(
                children: [
                  // Reset button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          ref.read(filterProvider.notifier).resetAll(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: filter.hasActiveFilters
                              ? AppColors.primary
                              : const Color(0xFFDDD5CC),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Reset',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: filter.hasActiveFilters
                              ? AppColors.primary
                              : AppColors.textMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Apply button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        // Pop back to search with filter applied
                        Navigator.of(context).maybePop(filter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Apply Filters',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          // Active filter count badge
                          if (filter.hasActiveFilters) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _countActive(filter).toString(),
                                style: GoogleFonts.lato(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _countActive(FilterState f) =>
      f.selectedWriters.length +
      f.selectedGenres.length +
      (f.selectedRating > 0 ? 1 : 0) +
      f.selectedPrices.length +
      f.selectedDiscounts.length;
}
