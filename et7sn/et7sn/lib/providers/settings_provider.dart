import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language and theme preferences, persisted on the device.
///
/// A null [locale] means "follow the device language" (automatic detection).
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs) {
    _themeMode = _readThemeMode();
    _locale = _readLocale();
  }

  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale';

  final SharedPreferences _prefs;
  late ThemeMode _themeMode;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;

  Locale? get locale => _locale;

  ThemeMode _readThemeMode() {
    final stored = _prefs.getString(_themeKey);
    for (final mode in ThemeMode.values) {
      if (mode.name == stored) return mode;
    }
    return ThemeMode.system;
  }

  Locale? _readLocale() {
    final stored = _prefs.getString(_localeKey);
    if (stored == 'en' || stored == 'ar') return Locale(stored!);
    return null;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    if (locale == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, locale.languageCode);
    }
  }
}
