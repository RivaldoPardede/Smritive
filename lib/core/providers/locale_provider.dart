import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'app_locale';

/// Manages the user's chosen app language independently of the system locale.
///
/// Persisted to [SharedPreferences] so the choice survives app restarts.
/// Placed above [MaterialApp] in the widget tree and consumed by the app root,
/// which passes [locale] directly to [MaterialApp.locale].
class LocaleProvider extends ChangeNotifier {
  LocaleProvider._(this._locale);

  Locale _locale;

  Locale get locale => _locale;

  bool get isEnglish => _locale.languageCode == 'en';

  /// Restores persisted locale or falls back to English.
  static Future<LocaleProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey) ?? 'en';
    return LocaleProvider._(Locale(code));
  }

  /// Toggles between English and Bahasa Indonesia.
  Future<void> toggle() async {
    _locale = isEnglish ? const Locale('id') : const Locale('en');
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _locale.languageCode);
  }
}
