import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/favorites_scope.dart';
import 'package:sup2i_food_mobile/app/notifications_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/mock_catalogue_repository.dart';
import 'package:sup2i_food_mobile/features/catalogue/presentation/product_detail_page.dart';
import 'package:sup2i_food_mobile/features/favorites/application/favorites_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/application/notifications_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/data/notifications_repository.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home) => FavoritesScope(
  controller: FavoritesController(),
  child: CartScope(
    controller: CartController(),
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

void main() {
  testWidgets('Affiche prix, allergènes (chips), options et note', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ProductDetailPage(
          productId: 'p1',
          repository: MockCatalogueRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tacos Poulet XL'), findsWidgets);
    expect(find.text('40,00 DH'), findsWidgets);
    expect(find.text('Allergènes'), findsOneWidget);
    expect(find.text('Gluten'), findsOneWidget);
    expect(find.text('Frites'), findsOneWidget);
    expect(find.text('Ajouter au panier'), findsOneWidget);
    expect(find.textContaining('Personnalisez'), findsOneWidget);
  });
}
