import 'dart:convert';
import 'package:pustakalaya/features/auth/data/models/user_model.dart';
import 'package:pustakalaya/features/auth/domain/entities/auth_failure.dart';
import 'package:pustakalaya/features/auth/domain/entities/user_entity.dart';
import 'package:pustakalaya/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _userKey = 'auth_user';

  // Simulated registered users store
  final Map<String, UserModel> _users = {};

  @override
  Future<({UserEntity? user, AuthFailure? failure})> signUp({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate network

    if (_users.containsKey(email)) {
      return (user: null, failure: const EmailAlreadyInUseFailure());
    }

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );
    _users[email] = user;
    await _persistUser(user);
    return (user: user, failure: null);
  }

  @override
  Future<({UserEntity? user, AuthFailure? failure})> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate network

    // For demo: any registered email works, or create on-the-fly
    final existing = _users[email];
    if (existing != null) {
      await _persistUser(existing);
      return (user: existing, failure: null);
    }

    // Auto-create for demo purposes (remove in production)
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: 'Reader',
      email: email,
      phoneNumber: '',
    );
    _users[email] = user;
    await _persistUser(user);
    return (user: user, failure: null);
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _persistUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
