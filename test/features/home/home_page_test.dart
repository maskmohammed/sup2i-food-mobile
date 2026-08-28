import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/favorites_scope.dart';
import 'package:sup2i_food_mobile/app/notifications_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/mock_catalogue_repository.dart';
import 'package:sup2i_food_mobile/features/favorites/application/favorites_controller.dart';
import 'package:sup2i_food_mobile/features/home/presentation/home_page.dart';
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

void main() {
  testWidgets('Accueil : sections et produits affichés', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const HomePage(
          repository: MockCatalogueRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nos coups de cœur'), findsOneWidget);
    expect(find.text('Nos catégories'), findsOneWidget);
    expect(find.text('Nos produits'), findsOneWidget);
    expect(find.text('Tacos Poulet XL'), findsWidgets);
  });
}
