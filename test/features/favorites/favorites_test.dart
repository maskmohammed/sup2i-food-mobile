import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/favorites_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/mock_catalogue_repository.dart';
import 'package:sup2i_food_mobile/features/favorites/application/favorites_controller.dart';
import 'package:sup2i_food_mobile/features/favorites/presentation/favorites_page.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(FavoritesController favorites, Widget home) => CartScope(
  controller: CartController(),
  child: FavoritesScope(
    controller: favorites,
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    ),
  ),
);

void main() {
  test('FavoritesController : toggle ajoute puis retire', () {
    final c = FavoritesController();
    expect(c.isFavorite('p1'), isFalse);
    c.toggle('p1');
    expect(c.isFavorite('p1'), isTrue);
    c.toggle('p1');
    expect(c.isFavorite('p1'), isFalse);
  });

  testWidgets('Favoris vides : état vide', (tester) async {
    await tester.pumpWidget(
      _wrap(
        FavoritesController(),
        const FavoritesPage(
          repository: MockCatalogueRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucun favori pour le moment.'), findsOneWidget);
  });

  testWidgets('Favoris : affiche uniquement les produits marqués', (
    tester,
  ) async {
    final favorites = FavoritesController()..toggle('p1');
    await tester.pumpWidget(
      _wrap(
        favorites,
        const FavoritesPage(
          repository: MockCatalogueRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tacos Poulet XL'), findsOneWidget);
    expect(find.text('Pizza margherita'), findsNothing);
  });
}
