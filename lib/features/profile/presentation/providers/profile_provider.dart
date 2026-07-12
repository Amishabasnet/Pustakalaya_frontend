import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/core/network/api_client.dart';
import 'package:pustakalaya/core/network/api_exception.dart';
import 'package:pustakalaya/features/auth/data/models/user_model.dart';
import 'package:pustakalaya/features/auth/presentation/providers/auth_provider.dart';
import 'package:pustakalaya/features/profile/domain/entities/profile_entity.dart';

final profileApiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient.instance,
);

class ProfileNotifier extends StateNotifier<ProfileEntity> {
  final Ref _ref;

  ProfileNotifier(this._ref)
    : super(
        const ProfileEntity(
          name: '',
          email: '',
          phoneNumber: '',
          totalOrders: 0,
          wishlistCount: 0,
          reviewsCount: 0,
        ),
      ) {
    refresh();
  }

  Future<void> refresh() async {
    final user = await _ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) return;

    int ordersPlaced = 0;
    int booksWishlisted = 0;
    int reviewsWritten = state.reviewsCount;
    try {
      final body = await _ref
          .read(profileApiClientProvider)
          .get('/auth/me/stats');
      ordersPlaced = (body['data']?['ordersPlaced'] as num?)?.toInt() ?? 0;
      booksWishlisted =
          (body['data']?['booksWishlisted'] as num?)?.toInt() ?? 0;
      reviewsWritten =
          (body['data']?['reviewsWritten'] as num?)?.toInt() ?? reviewsWritten;
    } on ApiException {
      // Stats are a nice-to-have — profile still renders without them.
    }

    state = ProfileEntity(
      name: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      totalOrders: ordersPlaced,
      wishlistCount: booksWishlisted,
      reviewsCount: reviewsWritten,
      username: user.username,
      address: user.address,
    );
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    String? username,
    String? address,
  }) async {
    final body = await _ref
        .read(profileApiClientProvider)
        .patch(
          '/auth/me',
          body: {
            'fullName': name,
            'email': email,
            'phoneNumber': phoneNumber,
            if (username != null && username.trim().isNotEmpty)
              'username': username.trim(),
            if (address != null && address.trim().isNotEmpty)
              'address': address.trim(),
          },
        );
    final userJson = body['data']?['user'];
    if (userJson != null) {
      final user = UserModel.fromJson(userJson as Map<String, dynamic>);
      state = state.copyWith(
        name: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        username: user.username,
        address: user.address,
      );
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileEntity>(
  (ref) => ProfileNotifier(ref),
);
