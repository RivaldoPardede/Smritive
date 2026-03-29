import 'package:flutter/foundation.dart';

import '../../data/auth_repository.dart';

enum RegisterStatus { idle, loading, success, error }

/// Drives the Register screen.
class RegisterProvider extends ChangeNotifier {
  RegisterProvider({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  RegisterStatus _status = RegisterStatus.idle;
  String? _errorMessage;

  RegisterStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == RegisterStatus.loading;
  bool get isSuccess => _status == RegisterStatus.success;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = RegisterStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.register(name: name, email: email, password: password);
      _status = RegisterStatus.success;
    } on AuthException catch (e) {
      _status = RegisterStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      _status = RegisterStatus.error;
      _errorMessage = 'An unexpected error occurred. Please try again.';
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status = RegisterStatus.idle;
    notifyListeners();
  }
}
