import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/core/router/app_router.dart';
import 'package:pustakalaya/features/profile/presentation/providers/profile_provider.dart';
import 'package:pustakalaya/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Orange header with avatar
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 32,
              ),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            profile.name[0],
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => context.push(AppRouter.editProfile),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.email,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBadge(
                        value: '${profile.totalOrders}',
                        label: 'Orders',
                      ),
                      _StatDivider(),
                      _StatBadge(
                        value: '${profile.wishlistCount}',
                        label: 'Wishlist',
                      ),
                      _StatDivider(),
                      _StatBadge(
                        value: '${profile.reviewsCount}',
                        label: 'Reviews',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Menu sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Account'),
                  const SizedBox(height: 10),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profile',
                        onTap: () => context.push(AppRouter.editProfile),
                      ),
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        label: 'Saved Addresses',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.payment_outlined,
                        label: 'Payment Methods',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Orders'),
                  const SizedBox(height: 10),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'My Orders',
                        badge: '${profile.totalOrders}',
                        onTap: () => context.go(AppRouter.myOrders),
                      ),
                      _MenuItem(
                        icon: Icons.replay_outlined,
                        label: 'Return & Refund',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.rate_review_outlined,
                        label: 'My Reviews',
                        badge: '${profile.reviewsCount}',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Preferences'),
                  const SizedBox(height: 10),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark Mode',
                        onTap: () {},
                        trailing: Switch(
                          value: false,
                          onChanged: (_) {},
                          activeThumbColor: AppColors.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        value: 'English',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Support'),
                  const SizedBox(height: 10),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & FAQ',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.assignment_return_outlined,
                        label: 'Return & Support',
                        onTap: () => context.push(AppRouter.returnSupport),
                      ),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'About Pustakalaya',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Sign out
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) context.go(AppRouter.signIn);
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
                      label: Text(
                        'Sign Out',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textMedium,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? badge;
  final String? value;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.value,
    this.trailing,
  });
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(item.icon, size: 18, color: AppColors.primary),
                ),
                title: Text(
                  item.label,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                trailing:
                    item.trailing ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.value != null)
                          Text(
                            item.value!,
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        if (item.badge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item.badge!,
                              style: GoogleFonts.lato(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.textMedium.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
              ),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  indent: 68,
                  color: AppColors.textMedium.withValues(alpha: 0.1),
                ),
            ],
          );
        }),
      ),
    );
  }
}
