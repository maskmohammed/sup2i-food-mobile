import 'package:shared_preferences/shared_preferences.dart';

/// Persistance locale des préférences utilisateur (langue, thème).
///
/// Abstraction pour rester testable (fake en mémoire dans les tests) et
/// découplée du plugin. Les valeurs sont stockées sous forme de chaînes :
/// code de langue (`fr`/`ar`/`en`) et nom du [ThemeMode] (`system`/`light`/
/// `dark`).
abstract interface class SettingsStore {
  Future<({String? localeCode, String? themeMode})> read();
  Future<void> writeLocale(String localeCode);
  Future<void> writeThemeMode(String themeMode);
}

/// Implémentation basée sur `shared_preferences`.
class SharedPreferencesSettingsStore implements SettingsStore {
  SharedPreferencesSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kLocale = 'settings.locale';
  static const String _kThemeMode = 'settings.themeMode';

  /// Ouvre le stockage partagé de la plateforme.
  static Future<SharedPreferencesSettingsStore> create() async =>
      SharedPreferencesSettingsStore(await SharedPreferences.getInstance());

  @override
  Future<({String? localeCode, String? themeMode})> read() async => (
    localeCode: _prefs.getString(_kLocale),
    themeMode: _prefs.getString(_kThemeMode),
  );

  @override
  Future<void> writeLocale(String localeCode) =>
      _prefs.setString(_kLocale, localeCode);

  @override
  Future<void> writeThemeMode(String themeMode) =>
      _prefs.setString(_kThemeMode, themeMode);
}
