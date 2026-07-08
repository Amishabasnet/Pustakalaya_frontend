import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:pustakalaya/features/wishlist/presentation/widgets/wishlist_book_card.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(filteredWishlistProvider);
    final allItems = ref.watch(wishlistProvider);
    final screenW = MediaQuery.of(context).size.width;
    final hPad = screenW > 600 ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE3),
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 20),
              child: Text(
                'Wishlist',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),

            // Search bar
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 20),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.textMedium.withValues(alpha: 0.55),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) =>
                            ref.read(wishlistSearchProvider.notifier).state = v,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search saved books',
                          hintStyle: GoogleFonts.lato(
                            fontSize: 14,
                            color: AppColors.textMedium.withValues(alpha: 0.55),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    // Clear button
                    if (_searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          ref.read(wishlistSearchProvider.notifier).state = '';
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textMedium,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 14),
                  ],
                ),
              ),
            ),

            // Book list
            Expanded(
              child: allItems.isEmpty
                  ? _EmptyState()
                  : items.isEmpty
                  ? _NoResultsState(query: _searchCtrl.text)
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return Dismissible(
                          key: Key(item.book.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 7,
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          onDismissed: (_) => ref
                              .read(wishlistProvider.notifier)
                              .remove(item.book.id),
                          child: WishlistBookCard(item: item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your wishlist is empty',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save books you love to find them here',
            style: GoogleFonts.lato(fontSize: 14, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;
  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppColors.textMedium.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            style: GoogleFonts.lato(
              fontSize: 15,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
