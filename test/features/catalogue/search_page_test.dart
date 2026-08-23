import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/favorites_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/mock_catalogue_repository.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/search_history_store.dart';
import 'package:sup2i_food_mobile/features/catalogue/presentation/search_page.dart';
import 'package:sup2i_food_mobile/features/favorites/application/favorites_controller.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

class _FakeHistory implements SearchHistoryStore {
  _FakeHistory([this.terms = const <String>[]]);
  List<String> terms;

  @override
  Future<List<String>> load() async => terms;

  @override
  Future<void> save(List<String> value) async => terms = value;
}

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
    await tester.pump(const Duration(milliseconds: 300)); // debounce
    await tester.pumpAndSettle();

    expect(find.text('Tacos Poulet XL'), findsOneWidget);
    expect(find.text('Pizza margherita'), findsNothing);
  });

  testWidgets('Aucun résultat : état vide dédié', (tester) async {
    await tester.pumpWidget(_wrap(_page));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pump(const Duration(milliseconds: 300)); // debounce
    await tester.pumpAndSettle();

    expect(find.text('Aucun résultat'), findsOneWidget);
    expect(find.text('Voir tout le catalogue'), findsOneWidget);
  });

  testWidgets('Champ vide : propose l\'historique récent', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SearchPage(
          repository: const MockCatalogueRepository(latency: Duration.zero),
          historyStore: _FakeHistory(['pizza', 'tacos']),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recherches récentes'), findsOneWidget);
    expect(find.text('pizza'), findsOneWidget);

    // Taper une recherche récente remplit le champ et filtre.
    await tester.tap(find.text('pizza'));
    await tester.pumpAndSettle();
    expect(find.text('Pizza margherita'), findsOneWidget);
    expect(find.text('Tacos Poulet XL'), findsNothing);
  });

  testWidgets('Debounce : filtre appliqué après la pause', (tester) async {
    await tester.pumpWidget(_wrap(_page));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'pizza');
    // Avant la fin du debounce : pas encore filtré.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Pizza margherita'), findsNothing);

    // Après la pause : résultats affichés.
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Pizza margherita'), findsOneWidget);
  });

  group('mergeRecentSearch', () {
    test('ajoute en tête et dédoublonne (insensible à la casse)', () {
      expect(mergeRecentSearch(['tacos'], 'Pizza'), ['Pizza', 'tacos']);
      expect(mergeRecentSearch(['tacos'], 'TACOS'), ['TACOS']);
    });

    test('plafonne à 5', () {
      final r = mergeRecentSearch(['a', 'b', 'c', 'd', 'e'], 'f');
      expect(r, ['f', 'a', 'b', 'c', 'd']);
    });

    test('ignore un terme vide', () {
      expect(mergeRecentSearch(['a'], '   '), ['a']);
    });
  });
}
