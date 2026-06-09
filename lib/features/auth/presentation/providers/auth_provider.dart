import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pustakalaya/features/auth/domain/entities/auth_failure.dart';
import 'package:pustakalaya/features/auth/domain/entities/user_entity.dart';
import 'package:pustakalaya/features/auth/domain/repositories/auth_repository.dart';
import 'package:pustakalaya/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:pustakalaya/features/auth/domain/usecases/sign_up_usecase.dart';

// Repository
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);

// Use cases
final signUpUseCaseProvider = Provider<SignUpUseCase>(
  (ref) => SignUpUseCase(ref.watch(authRepositoryProvider)),
);

final signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(ref.watch(authRepositoryProvider)),
);

// Auth State
enum AuthStatus { idle, loading, success, failure }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final AuthFailure? failure;

  const AuthState({this.status = AuthStatus.idle, this.user, this.failure});

  bool get isLoading => status == AuthStatus.loading;
  bool get isSuccess => status == AuthStatus.success;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    AuthFailure? failure,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    failure: failure ?? this.failure,
  );
}

// Sign Up Notifier
class SignUpNotifier extends StateNotifier<AuthState> {
  final SignUpUseCase _useCase;
  SignUpNotifier(this._useCase) : super(const AuthState());

  Future<void> signUp({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, failure: null);
    final result = await _useCase(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
    );
    if (result.failure != null) {
      state = state.copyWith(
        status: AuthStatus.failure,
        failure: result.failure,
      );
    } else {
      state = state.copyWith(status: AuthStatus.success, user: result.user);
    }
  }

  void reset() => state = const AuthState();
}

final signUpNotifierProvider = StateNotifierProvider<SignUpNotifier, AuthState>(
  (ref) => SignUpNotifier(ref.watch(signUpUseCaseProvider)),
);

// Sign In Notifier
class SignInNotifier extends StateNotifier<AuthState> {
  final SignInUseCase _useCase;
  SignInNotifier(this._useCase) : super(const AuthState());

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, failure: null);
    final result = await _useCase(email: email, password: password);
    if (result.failure != null) {
      state = state.copyWith(
        status: AuthStatus.failure,
        failure: result.failure,
      );
    } else {
      state = state.copyWith(status: AuthStatus.success, user: result.user);
    }
  }

  void reset() => state = const AuthState();
}

final signInNotifierProvider = StateNotifierProvider<SignInNotifier, AuthState>(
  (ref) => SignInNotifier(ref.watch(signInUseCaseProvider)),
);
