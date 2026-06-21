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

  ProfileEntity copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    int? totalOrders,
    int? wishlistCount,
    int? reviewsCount,
  }) {
    return ProfileEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      totalOrders: totalOrders ?? this.totalOrders,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }
}
