abstract class AuthFailure {
  final String message;
  const AuthFailure(this.message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Invalid email or password.');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('This email is already registered.');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure()
    : super('Password must be at least 6 characters.');
}

class ServerFailure extends AuthFailure {
  const ServerFailure([String msg = 'Something went wrong. Please try again.'])
    : super(msg);
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure() : super('No internet connection.');
}
