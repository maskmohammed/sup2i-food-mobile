import 'package:flutter/material.dart';

/// Réglages application : langue et thème (clair/sombre/système).
/// En mémoire pour l'instant ; à persister (shared_preferences) quand la
/// dépendance pourra être ajoutée.
class SettingsController extends ChangeNotifier {
  Locale _locale = const Locale('fr');
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  void setLocale(Locale locale) {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
  }
}
