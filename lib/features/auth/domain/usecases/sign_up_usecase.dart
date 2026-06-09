import 'package:pustakalaya/features/auth/domain/entities/auth_failure.dart';
import 'package:pustakalaya/features/auth/domain/entities/user_entity.dart';
import 'package:pustakalaya/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;
  const SignUpUseCase(this._repository);

  Future<({UserEntity? user, AuthFailure? failure})> call({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  }) {
    if (password.length < 6) {
      return Future.value((user: null, failure: const WeakPasswordFailure()));
    }
    return _repository.signUp(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
    );
  }
}
