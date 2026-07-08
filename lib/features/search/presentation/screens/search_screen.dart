import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/core/router/app_router.dart';
import 'package:pustakalaya/features/book_detail/presentation/providers/book_detail_provider.dart';
import 'package:pustakalaya/features/filter/domain/entities/filter_state.dart';
import 'package:pustakalaya/features/filter/presentation/providers/filter_provider.dart';
import 'package:pustakalaya/features/home/presentation/providers/home_provider.dart';
import 'package:pustakalaya/features/search/presentation/providers/search_provider.dart';
import 'package:pustakalaya/features/search/presentation/widgets/recent_search_chip.dart';
import 'package:pustakalaya/features/search/presentation/widgets/recommended_book_card.dart';
import 'package:pustakalaya/features/search/presentation/widgets/search_result_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialSection;

  const SearchScreen({super.key, this.initialSection});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sectionFilterProvider.notifier).state = widget.initialSection;
      if (widget.initialSection == null) {
        _focusNode.requestFocus();
      }
    });
    _searchCtrl.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchCtrl.text;
      if (_searchCtrl.text.isNotEmpty &&
          ref.read(sectionFilterProvider) != null) {
        ref.read(sectionFilterProvider.notifier).state = null;
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    ref.read(recentSearchesProvider.notifier).add(query.trim());
    ref.read(searchQueryProvider.notifier).state = query.trim();
    _searchCtrl.text = query.trim();
    _focusNode.unfocus();
  }

  void _navigateToBook(book) {
    ref.read(selectedBookProvider.notifier).state = book;
    ref.read(bookQuantityProvider.notifier).state = 1;
    context.push(AppRouter.bookDetail);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final sectionFilter = ref.watch(sectionFilterProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final resultsState = ref.watch(searchResultsProvider);
    final results = resultsState.books;
    final recommendedAsync = ref.watch(filteredBrowseProvider);
    final activeFilters = ref.watch(filterProvider);
    final screenW = MediaQuery.of(context).size.width;
    final hPad = screenW > 600 ? 32.0 : 16.0;
    final isSearching = query.trim().isNotEmpty;
    final hasSectionFilter = sectionFilter != null && !isSearching;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 14),
              child: Column(
                children: [
                  // Title row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Search',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F0EB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _focusNode.hasFocus
                                  ? AppColors.primary.withOpacity(0.5)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Icon(
                                Icons.search_rounded,
                                size: 20,
                                color: AppColors.textMedium.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  focusNode: _focusNode,
                                  onSubmitted: _onSearch,
                                  textInputAction: TextInputAction.search,
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search books',
                                    hintStyle: GoogleFonts.lato(
                                      fontSize: 14,
                                      color: AppColors.textMedium.withOpacity(
                                        0.55,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (query.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    ref
                                            .read(searchQueryProvider.notifier)
                                            .state =
                                        '';
                                    _focusNode.requestFocus();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  if (hasSectionFilter) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sectionFilter == 'featured'
                                    ? 'Featured'
                                    : 'Recently Added',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  ref
                                          .read(sectionFilterProvider.notifier)
                                          .state =
                                      null;
                                  _focusNode.requestFocus();
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEE8E0)),

            Expanded(
              child: isSearching
                  ? _SearchResults(
                      results: results,
                      query: query,
                      hPad: hPad,
                      onTap: _navigateToBook,
                      onQueryTap: _onSearch,
                      hasMore: resultsState.hasMore,
                      isLoadingMore: resultsState.isLoadingMore,
                      onLoadMore: () => ref.read(searchResultsProvider.notifier).loadMore(),
                    )
                  : hasSectionFilter
                  ? _SectionView(
                      section: sectionFilter,
                      hPad: hPad,
                      onBookTap: _navigateToBook,
                    )
                  : _DefaultView(
                      recentSearches: recentSearches,
                      recommendedAsync: recommendedAsync,
                      hPad: hPad,
                      activeFilters: activeFilters,
                      onChipTap: _onSearch,
                      onRemoveChip: (s) =>
                          ref.read(recentSearchesProvider.notifier).remove(s),
                      onClearAll: () =>
                          ref.read(recentSearchesProvider.notifier).clearAll(),
                      onClearFilters: () =>
                          ref.read(filterProvider.notifier).resetAll(),
                      onBookTap: _navigateToBook,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionView extends ConsumerWidget {
  final String section;
  final double hPad;
  final Function(dynamic) onBookTap;

  const _SectionView({
    required this.section,
    required this.hPad,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = section == 'featured'
        ? ref.watch(featuredBooksProvider)
        : ref.watch(recentlyAddedProvider);

    final title = section == 'featured' ? 'Featured Books' : 'Recently Added';

    return booksAsync.when(
      data: (books) => ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              '${books.length} book${books.length == 1 ? '' : 's'} · $title',
              style: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...books.map(
            (book) =>
                RecommendedBookCard(book: book, onTap: () => onBookTap(book)),
          ),
        ],
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _DefaultView extends StatelessWidget {
  final List<String> recentSearches;
  final AsyncValue recommendedAsync;
  final double hPad;
  final FilterState activeFilters;
  final ValueChanged<String> onChipTap;
  final ValueChanged<String> onRemoveChip;
  final VoidCallback onClearAll;
  final VoidCallback onClearFilters;
  final Function(dynamic) onBookTap;

  const _DefaultView({
    required this.recentSearches,
    required this.recommendedAsync,
    required this.hPad,
    required this.activeFilters,
    required this.onChipTap,
    required this.onRemoveChip,
    required this.onClearAll,
    required this.onClearFilters,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
      children: [
        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT SEARCHES',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMedium,
                  letterSpacing: 0.8,
                ),
              ),
              GestureDetector(
                onTap: onClearAll,
                child: Text(
                  'Clear all',
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches
                .map(
                  (s) => RecentSearchChip(
                    label: s,
                    onTap: () => onChipTap(s),
                    onRemove: () => onRemoveChip(s),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 26),
        ],

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              activeFilters.hasActiveFilters
                  ? 'FILTERED RESULTS'
                  : 'HIGHLY RECOMMENDED',
              style: GoogleFonts.lato(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMedium,
                letterSpacing: 0.8,
              ),
            ),
            if (activeFilters.hasActiveFilters)
              GestureDetector(
                onTap: onClearFilters,
                child: Text(
                  'Clear filters',
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        recommendedAsync.when(
          data: (books) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.58,
            ),
            itemCount: books.length,
            itemBuilder: (_, i) => RecommendedBookCard(
              book: books[i],
              onTap: () => onBookTap(books[i]),
            ),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List results;
  final String query;
  final double hPad;
  final Function(dynamic) onTap;
  final ValueChanged<String> onQueryTap;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  const _SearchResults({
    required this.results,
    required this.query,
    required this.hPad,
    required this.onTap,
    required this.onQueryTap,
    this.hasMore = false,
    this.isLoadingMore = false,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 60,
                color: AppColors.textMedium.withOpacity(0.35),
              ),
              const SizedBox(height: 16),
              Text(
                'No results for "$query"',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different keyword or browse\nour recommendations.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (hasMore &&
            !isLoadingMore &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${results.length} result${results.length == 1 ? '' : 's'} for "$query"',
              style: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...results.map(
            (book) => SearchResultTile(
              book: book,
              query: query,
              onTap: () => onTap(book),
            ),
          ),
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
