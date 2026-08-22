import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/features/settings/application/settings_controller.dart';
import 'package:sup2i_food_mobile/features/settings/data/settings_store.dart';

/// Store en mémoire simulant shared_preferences.
class _FakeStore implements SettingsStore {
  _FakeStore({this.localeCode, this.themeMode});

  String? localeCode;
  String? themeMode;

  @override
  Future<({String? localeCode, String? themeMode})> read() async =>
      (localeCode: localeCode, themeMode: themeMode);

  @override
  Future<void> writeLocale(String value) async => localeCode = value;

  @override
  Future<void> writeThemeMode(String value) async => themeMode = value;
}

void main() {
  test('valeurs par défaut : fr + system', () {
    final c = SettingsController();
    expect(c.locale, const Locale('fr'));
    expect(c.themeMode, ThemeMode.system);
  });

  test('load() applique les préférences persistées', () async {
    final c = SettingsController(
      _FakeStore(localeCode: 'ar', themeMode: 'dark'),
    );
    await c.load();
    expect(c.locale, const Locale('ar'));
    expect(c.themeMode, ThemeMode.dark);
  });

  test('load() ignore un code de langue non supporté', () async {
    final c = SettingsController(_FakeStore(localeCode: 'zz'));
    await c.load();
    expect(c.locale, const Locale('fr'));
  });

  test('setLocale / setThemeMode écrivent dans le store', () async {
    final store = _FakeStore();
    final c = SettingsController(store);
    c.setLocale(const Locale('en'));
    c.setThemeMode(ThemeMode.light);
    expect(store.localeCode, 'en');
    expect(store.themeMode, 'light');
  });

  test('round-trip : ce qui est écrit est rechargé', () async {
    final store = _FakeStore();
    SettingsController(store)
      ..setLocale(const Locale('ar'))
      ..setThemeMode(ThemeMode.dark);

    final reloaded = SettingsController(store);
    await reloaded.load();
    expect(reloaded.locale, const Locale('ar'));
    expect(reloaded.themeMode, ThemeMode.dark);
  });
}
