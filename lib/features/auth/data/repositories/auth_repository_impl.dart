import 'package:pustakalaya/core/network/api_client.dart';
import 'package:pustakalaya/core/network/api_exception.dart';
import 'package:pustakalaya/core/network/token_storage.dart';
import 'package:pustakalaya/features/auth/data/models/user_model.dart';
import 'package:pustakalaya/features/auth/domain/entities/auth_failure.dart';
import 'package:pustakalaya/features/auth/domain/entities/user_entity.dart';
import 'package:pustakalaya/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _client = ApiClient.instance;

  UserModel? _cachedUser;

  @override
  Future<({UserEntity? user, AuthFailure? failure})> signUp({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    try {
      final body = await _client.post(
        '/auth/signup',
        body: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'email': email,
          'password': password,
          'confirmPassword': password,
        },
      );
      return _handleAuthResponse(body);
    } on ApiException catch (e) {
      return (user: null, failure: _mapFailure(e));
    }
  }

  @override
  Future<({UserEntity? user, AuthFailure? failure})> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final body = await _client.post(
        '/auth/signin',
        body: {'email': email, 'password': password},
      );
      return _handleAuthResponse(body);
    } on ApiException catch (e) {
      return (user: null, failure: _mapFailure(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.post('/auth/signout');
    } on ApiException catch (_) {
      // Even if the network call fails, still clear local session below.
    }
    _cachedUser = null;
    await TokenStorage.instance.clear();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await TokenStorage.instance.read();
    if (token == null || token.isEmpty) return null;

    try {
      final body = await _client.get('/auth/me');
      final userJson = body['data']?['user'];
      if (userJson == null) return null;
      _cachedUser = UserModel.fromJson(userJson as Map<String, dynamic>);
      return _cachedUser;
    } on ApiException {
      // Token expired/invalid — clear it so the user is sent back to sign in.
      await TokenStorage.instance.clear();
      return null;
    }
  }

  Future<({UserEntity? user, AuthFailure? failure})> _handleAuthResponse(
    Map<String, dynamic> body,
  ) async {
    final data = body['data'] as Map<String, dynamic>?;
    final accessToken = data?['accessToken'] as String?;
    final userJson = data?['user'] as Map<String, dynamic>?;

    if (accessToken == null || userJson == null) {
      return (user: null, failure: const ServerFailure());
    }

    await TokenStorage.instance.save(accessToken);
    _cachedUser = UserModel.fromJson(userJson);
    return (user: _cachedUser, failure: null);
  }

  AuthFailure _mapFailure(ApiException e) {
    if (e.isNetworkError) return const NetworkFailure();
    if (e.statusCode == 409) return const EmailAlreadyInUseFailure();
    if (e.statusCode == 401 || e.statusCode == 403) {
      return const InvalidCredentialsFailure();
    }
    if (e.statusCode == 422 && e.fieldErrors.isNotEmpty) {
      return ServerFailure(e.fieldErrors.first.message);
    }
    return ServerFailure(e.message);
  }
}
 