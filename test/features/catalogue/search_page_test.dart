import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/favorites_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/mock_catalogue_repository.dart';
import 'package:sup2i_food_mobile/features/catalogue/presentation/search_page.dart';
import 'package:sup2i_food_mobile/features/favorites/application/favorites_controller.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home) => CartScope(
  controller: CartController(),
  child: FavoritesScope(
    controller: FavoritesController(),
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    ),
  ),
);

const _page = SearchPage(
  repository: MockCatalogueRepository(latency: Duration.zero),
);

void main() {
  testWidgets('Champ vide : invite, aucun produit', (tester) async {
    await tester.pumpWidget(_wrap(_page));
    await tester.pumpAndSettle();

    expect(find.text('Tapez pour rechercher un produit'), findsOneWidget);
    expect(find.text('Tacos Poulet XL'), findsNothing);
  });

  testWidgets('Filtre par nom, insensible à la casse', (tester) async {
    await tester.pumpWidget(_wrap(_page));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'TACOS');
    await tester.pumpAndSettle();

    expect(find.text('Tacos Poulet XL'), findsOneWidget);
    expect(find.text('Pizza margherita'), findsNothing);
  });

  testWidgets('Aucun résultat : état vide dédié', (tester) async {
    await tester.pumpWidget(_wrap(_page));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pumpAndSettle();

    expect(find.text('Aucun résultat'), findsOneWidget);
    expect(find.text('Voir tout le catalogue'), findsOneWidget);
  });
}
