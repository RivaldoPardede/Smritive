import '../../../core/network/api_service.dart';
import '../domain/login_result.dart';

/// Translates raw API responses into typed results or throws [AuthException].
class AuthRepository {
  const AuthRepository(this._api);

  final ApiService _api;

  /// Registers a new user. Throws [AuthException] on API-level errors.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final body = await _api.register(name: name, email: email, password: password);
    if (body['error'] == true) {
      throw AuthException(body['message'] as String? ?? 'Registration failed');
    }
  }

  /// Logs in and returns a [LoginResult]. Throws [AuthException] on failure.
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final body = await _api.login(email: email, password: password);
    if (body['error'] == true) {
      throw AuthException(body['message'] as String? ?? 'Login failed');
    }
    return LoginResult.fromJson(body['loginResult'] as Map<String, dynamic>);
  }
}

/// Thrown when the auth API returns an error response.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
