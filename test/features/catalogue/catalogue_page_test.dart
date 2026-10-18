import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/favorites_scope.dart';
import 'package:sup2i_food_mobile/app/notifications_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/mock_catalogue_repository.dart';
import 'package:sup2i_food_mobile/features/catalogue/presentation/catalogue_page.dart';
import 'package:sup2i_food_mobile/features/catalogue/presentation/widgets/loading_skeletons.dart';
import 'package:sup2i_food_mobile/features/favorites/application/favorites_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/application/notifications_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/data/notifications_repository.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home) => CartScope(
  controller: CartController(),
  child: FavoritesScope(
    controller: FavoritesController(),
    child: NotificationsScope(
      controller: NotificationsController(
        MockNotificationsRepository(latency: Duration.zero),
      )..load(),
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: home,
      ),
    ),
  ),
);

const _page = CataloguePage(
  repository: MockCatalogueRepository(latency: Duration.zero),
);

void main() {
  testWidgets('Affiche un skeleton pendant le chargement', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CataloguePage(
          repository: MockCatalogueRepository(
            latency: Duration(milliseconds: 300),
          ),
        ),
      ),
    );
    // Une frame : chargement en cours -> skeleton visible, pas encore de produit.
    await tester.pump();
    expect(find.byType(CatalogueSkeleton), findsOneWidget);
    expect(find.text('Tacos Poulet XL'), findsNothing);

    // Après le délai, le skeleton disparaît au profit des produits.
    await tester.pumpAndSettle();
    expect(find.byType(CatalogueSkeleton), findsNothing);
    expect(find.text('Tacos Poulet XL'), findsOneWidget);
  });

  testWidgets('Affiche les produits et les prix au format DH', (tester) async {
    await tester.pumpWidget(_wrap(_page));
    await tester.pumpAndSettle();

    expect(find.text('Tacos Poulet XL'), findsOneWidget);
    expect(find.text('40,00 DH'), findsWidgets);
    // Pull-to-refresh câblé (point 4).
    expect(find.byType(RefreshIndicator), findsOneWidget);
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

    await tester.ensureVisible(find.text('Tacos Poulet XL').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tacos Poulet XL').first);
    await tester.pumpAndSettle();

    expect(find.text('Allergènes'), findsOneWidget);
  });
}
