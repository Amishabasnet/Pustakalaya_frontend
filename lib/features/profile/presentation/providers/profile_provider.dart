import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/profile/domain/entities/profile_entity.dart';

class ProfileNotifier extends StateNotifier<ProfileEntity> {
  ProfileNotifier()
    : super(
        const ProfileEntity(
          name: 'Amisha Basnet',
          email: 'amishabasnet@gmail.com',
          phoneNumber: '+977 9874563210',
          totalOrders: 12,
          wishlistCount: 5,
          reviewsCount: 8,
        ),
      );

  void updateProfile({String? name, String? email, String? phoneNumber}) {
    state = state.copyWith(name: name, email: email, phoneNumber: phoneNumber);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileEntity>(
  (ref) => ProfileNotifier(),
);
