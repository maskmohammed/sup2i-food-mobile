import 'package:flutter/material.dart';

import '../data/settings_store.dart';
import '../../../l10n/app_localizations.dart';

/// Réglages application : langue et thème (clair/sombre/système).
///
/// Persistés via un [SettingsStore] optionnel (shared_preferences en prod,
/// null en tests → purement en mémoire). Les changements sont appliqués
/// immédiatement puis écrits en tâche de fond.
class SettingsController extends ChangeNotifier {
  SettingsController([this._store]);

  final SettingsStore? _store;

  Locale _locale = const Locale('fr');
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  /// Charge les préférences persistées et notifie si elles diffèrent des
  /// valeurs par défaut. Sans store, ne fait rien.
  Future<void> load() async {
    final store = _store;
    if (store == null) return;
    final data = await store.read();
    var changed = false;

    final code = data.localeCode;
    if (code != null && _isSupported(code)) {
      _locale = Locale(code);
      changed = true;
    }
    final theme = data.themeMode;
    if (theme != null) {
      _themeMode = _parseThemeMode(theme);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setLocale(Locale locale) {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    _store?.writeLocale(locale.languageCode);
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    _store?.writeThemeMode(mode.name);
  }

  bool _isSupported(String code) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code);

  ThemeMode _parseThemeMode(String value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
