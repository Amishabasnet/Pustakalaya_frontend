import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/core/router/app_router.dart';
import 'package:pustakalaya/features/home/presentation/providers/home_provider.dart';
import 'package:pustakalaya/features/home/presentation/widgets/featured_book_card.dart';
import 'package:pustakalaya/features/home/presentation/widgets/recently_added_tile.dart';
import 'package:pustakalaya/features/notifications/presentation/providers/notifications_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredBooksProvider);
    final recentlyAsync = ref.watch(recentlyAddedProvider);
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      body: RefreshIndicator(
        onRefresh: () async {
          // Re-fetch home data from the backend — picks up anything changed
          // in the admin panel (new/verified/featured books, stock, etc.)
          // since this screen was first loaded.
          ref.invalidate(featuredBooksProvider);
          ref.invalidate(recentlyAddedProvider);
          ref.invalidate(genresProvider);
          await Future.wait([
            ref.read(featuredBooksProvider.future),
            ref.read(recentlyAddedProvider.future),
          ]);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top app bar
            SliverAppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              pinned: true,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.textDark,
                    size: 26,
                  ),
                  onPressed: () {},
                ),
              ),
              title: Text(
                'Home',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final unreadCount = ref.watch(unreadCountProvider);
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textDark,
                              size: 24,
                            ),
                            onPressed: () =>
                                context.push(AppRouter.notifications),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      _hPad(screenW),
                      24,
                      _hPad(screenW),
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Which book do\nyou want to buy?',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: _heroFontSize(screenW),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '40,000+ titles available',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      _hPad(screenW),
                      18,
                      _hPad(screenW),
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push(AppRouter.search),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 14),
                                  Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textMedium.withValues(
                                      alpha: 0.55,
                                    ),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Search books',
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      color: AppColors.textMedium.withValues(
                                        alpha: 0.55,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Filter button — opens Search then Filter
                        GestureDetector(
                          onTap: () => context.push(AppRouter.filter),
                          child: Container(
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
                        ),
                      ],
                    ),
                  ),

                  // Featured section
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      _hPad(screenW),
                      28,
                      _hPad(screenW),
                      12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Featured',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(
                            AppRouter.search,
                            extra: {'section': 'featured'},
                          ),
                          child: Text(
                            'See all',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Featured horizontal scroll
            SliverToBoxAdapter(
              child: featuredAsync.when(
                data: (books) => SizedBox(
                  height: _featuredHeight(screenW),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: _hPad(screenW)),
                    itemCount: books.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (_, i) => FeaturedBookCard(book: books[i]),
                  ),
                ),
                loading: () => SizedBox(
                  height: _featuredHeight(screenW),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: _hPad(screenW)),
                    itemCount: 3,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (_, _) => _ShimmerCard(
                      width: screenW * 0.42,
                      height: _featuredHeight(screenW),
                    ),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  _hPad(screenW),
                  28,
                  _hPad(screenW),
                  12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recently Added',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(
                        AppRouter.search,
                        extra: {'section': 'recent'},
                      ),
                      child: Text(
                        'See all',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: recentlyAsync.when(
                data: (books) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: _hPad(screenW)),
                  child: Column(
                    children: books
                        .map((b) => RecentlyAddedTile(book: b))
                        .toList(),
                  ),
                ),
                loading: () => Padding(
                  padding: EdgeInsets.symmetric(horizontal: _hPad(screenW)),
                  child: Column(
                    children: List.generate(
                      3,
                      (_) => _ShimmerCard(width: double.infinity, height: 110),
                    ),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  static double _hPad(double w) => w > 600 ? 32 : 20;
  static double _heroFontSize(double w) => w > 600 ? 34 : 28;
  static double _featuredHeight(double w) {
    final cardW = (w * 0.42).clamp(150.0, 185.0);
    return cardW * 1.28 + 92; // cover + info section
  }
}

class _ShimmerCard extends StatefulWidget {
  final double width;
  final double height;
  const _ShimmerCard({required this.width, required this.height});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.5, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        width: widget.width,
        height: widget.height,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey[300]!.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
