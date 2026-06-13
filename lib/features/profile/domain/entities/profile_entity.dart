class ProfileEntity {
  final String name;
  final String email;
  final String phoneNumber;
  final int totalOrders;
  final int wishlistCount;
  final int reviewsCount;

  const ProfileEntity({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.totalOrders,
    required this.wishlistCount,
    required this.reviewsCount,
  });
}
