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
  const ServerFailure([
    String message = 'Something went wrong. Please try again.',
  ]) : super(message);
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure()
    : super(
        'Couldn\'t reach the server. Make sure the backend is running and the API URL is correct.\nIf you\'re running the app in a browser, ensure the backend allows CORS or set `API_BASE_URL` via `--dart-define` to a reachable address.',
      );
}
