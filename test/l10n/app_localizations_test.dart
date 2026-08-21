import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

void main() {
  test('FR : langue par défaut, LTR', () {
    const loc = AppLocalizations(Locale('fr'));
    expect(loc.textDirection, TextDirection.ltr);
    expect(loc.navHome, 'Accueil');
    expect(loc.navOrders, 'Commandes');
  });

  test('AR : traductions et direction RTL', () {
    const loc = AppLocalizations(Locale('ar'));
    expect(loc.textDirection, TextDirection.rtl);
    expect(loc.navProfile, 'حسابي');
  });

  test('EN : traductions, LTR', () {
    const loc = AppLocalizations(Locale('en'));
    expect(loc.textDirection, TextDirection.ltr);
    expect(loc.navCanteen, 'Canteen');
  });

  test('Langue non supportée : repli sur le FR', () {
    const loc = AppLocalizations(Locale('es'));
    expect(loc.navHome, 'Accueil');
  });
}
