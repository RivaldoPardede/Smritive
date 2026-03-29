import 'package:flutter/foundation.dart';

import '../../data/auth_repository.dart';
import '../providers/auth_provider.dart';

enum AuthStatus { idle, loading, success, error }

/// Drives the Login screen.
///
/// Injected at the route level — not at the app root — to scope its lifecycle
/// to the login screen.
class LoginProvider extends ChangeNotifier {
  LoginProvider({
    required AuthRepository repository,
    required AuthProvider authProvider,
  }) : _repository = repository,
       _authProvider = authProvider;

  final AuthRepository _repository;
  final AuthProvider _authProvider;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.login(email: email, password: password);
      await _authProvider.saveSession(
        token: result.token,
        userId: result.userId,
        name: result.name,
      );
      _status = AuthStatus.success;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred. Please try again.';
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }
}
