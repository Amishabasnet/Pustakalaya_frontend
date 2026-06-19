import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/filter_state.dart';
import '../providers/filter_provider.dart';
import 'filter_section_label.dart';
import 'star_rating_selector.dart';

class FilterTabContent extends ConsumerWidget {
  final FilterTab tab;

  const FilterTabContent({super.key, required this.tab});

  static const _writers = [
    'J.K.Rowling',
    'Paulo Coelho',
    'James Clear',
    'Collen Hover',
    'William Gibson',
  ];

  static const _genres = [
    'Romance',
    'Literacy Fiction',
    'Thriller',
    'Self-Help',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FilterSectionLabel('WRITER'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _writers
                .map(
                  (w) => FilterChip(
                    label: Text(w),
                    selected: filter.selectedWriters.contains(w),
                    onSelected: (_) => notifier.toggleWriter(w),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, color: Color(0xFFEEE5DC)),
          const SizedBox(height: 22),

          const FilterSectionLabel('GENRE'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _genres
                .map(
                  (g) => FilterChip(
                    label: Text(g),
                    selected: filter.selectedGenres.contains(g),
                    onSelected: (_) => notifier.toggleGenre(g),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, color: Color(0xFFEEE5DC)),
          const SizedBox(height: 22),

          if (tab == FilterTab.onSale) ...[
            const FilterSectionLabel('DISCOUNT'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DiscountRange.values
                  .map(
                    (d) => FilterChip(
                      label: Text(d.label),
                      selected: filter.selectedDiscounts.contains(d),
                      onSelected: (_) => notifier.toggleDiscount(d),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 22),
            const Divider(height: 1, color: Color(0xFFEEE5DC)),
            const SizedBox(height: 22),
          ],

          const FilterSectionLabel('RATING'),
          StarRatingSelector(
            selectedRating: filter.selectedRating,
            onTap: notifier.setRating,
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, color: Color(0xFFEEE5DC)),
          const SizedBox(height: 22),

          const FilterSectionLabel('PRICING'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PriceRange.values
                .map(
                  (p) => FilterChip(
                    label: Text(p.label),
                    selected: filter.selectedPrices.contains(p),
                    onSelected: (_) => notifier.togglePrice(p),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
