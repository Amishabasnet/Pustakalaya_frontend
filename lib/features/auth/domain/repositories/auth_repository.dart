import 'package:pustakalaya/features/auth/domain/entities/auth_failure.dart';
import 'package:pustakalaya/features/auth/domain/entities/user_entity.dart';

/// Abstract contract — data layer must implement this.
abstract class AuthRepository {
  Future<({UserEntity? user, AuthFailure? failure})> signUp({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  });

  Future<({UserEntity? user, AuthFailure? failure})> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserEntity?> getCurrentUser();
}
