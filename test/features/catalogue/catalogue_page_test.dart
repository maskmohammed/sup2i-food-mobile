import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/mock_catalogue_repository.dart';
import 'package:sup2i_food_mobile/features/catalogue/presentation/catalogue_page.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('fr'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: home,
);

const _page = CataloguePage(
  repository: MockCatalogueRepository(latency: Duration.zero),
);

void main() {
  testWidgets('Affiche les produits et les prix au format DH', (tester) async {
    await tester.pumpWidget(_wrap(_page));
    await tester.pumpAndSettle();

    expect(find.text('Tacos Poulet XL'), findsOneWidget);
    expect(find.text('40,00 DH'), findsWidgets);
  });

  testWidgets('Filtre par catégorie (Pizza)', (tester) async {
    await tester.pumpWidget(_wrap(_page));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pizza'));
    await tester.pumpAndSettle();

    expect(find.text('Pizza margherita'), findsOneWidget);
    expect(find.text('Tacos Poulet XL'), findsNothing);
  });

  testWidgets('Produit indisponible : badge Indisponible', (tester) async {
    await tester.pumpWidget(_wrap(_page));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Boisson'));
    await tester.pumpAndSettle();

    expect(find.text('Indisponible'), findsOneWidget);
  });

  testWidgets('Tap sur une carte ouvre le détail produit', (tester) async {
    await tester.pumpWidget(_wrap(_page));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tacos Poulet XL'));
    await tester.pumpAndSettle();

    expect(find.text('Allergènes'), findsOneWidget);
  });
}
