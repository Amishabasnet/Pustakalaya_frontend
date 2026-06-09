import 'package:pustakalaya/features/auth/domain/entities/auth_failure.dart';
import 'package:pustakalaya/features/auth/domain/entities/user_entity.dart';
import 'package:pustakalaya/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;
  const SignInUseCase(this._repository);

  Future<({UserEntity? user, AuthFailure? failure})> call({
    required String email,
    required String password,
  }) {
    if (email.isEmpty || password.isEmpty) {
      return Future.value((
        user: null,
        failure: const InvalidCredentialsFailure(),
      ));
    }
    return _repository.signIn(email: email, password: password);
  }
}
