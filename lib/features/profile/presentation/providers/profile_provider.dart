import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pustakalaya/features/profile/domain/entities/profile_entity.dart';

final profileProvider = Provider<ProfileEntity>(
  (ref) => const ProfileEntity(
    name: 'Amisha Basnet',
    email: 'amishabasnet@gmail.com',
    phoneNumber: '+977 9874563210',
    totalOrders: 12,
    wishlistCount: 5,
    reviewsCount: 8,
  ),
);
