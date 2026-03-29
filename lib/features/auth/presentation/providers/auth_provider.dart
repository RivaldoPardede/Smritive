import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys used to persist auth data in SharedPreferences.
class _PrefKeys {
  static const String token = 'auth_token';
  static const String userId = 'auth_user_id';
  static const String name = 'auth_user_name';
}

/// Manages authentication session state and persistence.
///
/// Implements [ChangeNotifier] so GoRouter can use it as a [refreshListenable].
class AuthProvider extends ChangeNotifier {
  AuthProvider._();

  static Future<AuthProvider> create() async {
    final instance = AuthProvider._();
    await instance._loadSession();
    return instance;
  }

  String? _token;
  String? _userId;
  String? _userName;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;

  /// Called after a successful login API response.
  Future<void> saveSession({
    required String token,
    required String userId,
    required String name,
  }) async {
    _token = token;
    _userId = userId;
    _userName = name;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_PrefKeys.token, token);
    await prefs.setString(_PrefKeys.userId, userId);
    await prefs.setString(_PrefKeys.name, name);

    notifyListeners();
  }

  /// Clears session on logout.
  Future<void> clearSession() async {
    _token = null;
    _userId = null;
    _userName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_PrefKeys.token);
    await prefs.remove(_PrefKeys.userId);
    await prefs.remove(_PrefKeys.name);

    notifyListeners();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_PrefKeys.token);
    _userId = prefs.getString(_PrefKeys.userId);
    _userName = prefs.getString(_PrefKeys.name);
  }
}
