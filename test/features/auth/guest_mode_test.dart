import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/auth_scope.dart';
import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/favorites_scope.dart';
import 'package:sup2i_food_mobile/app/notifications_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/auth/application/auth_controller.dart';
import 'package:sup2i_food_mobile/features/auth/data/mock_auth_repository.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/mock_catalogue_repository.dart';
import 'package:sup2i_food_mobile/features/catalogue/presentation/catalogue_page.dart';
import 'package:sup2i_food_mobile/features/favorites/application/favorites_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/application/notifications_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/data/notifications_repository.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(
  Widget home, {
  required AuthController auth,
  CartController? cart,
}) => AuthScope(
  controller: auth,
  child: CartScope(
    controller: cart ?? CartController(),
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
  ),
);

const _catalogue = CataloguePage(
  repository: MockCatalogueRepository(latency: Duration.zero),
);

void main() {
  testWidgets('Invité : ajout au panier déclenche le mur de connexion', (
    tester,
  ) async {
    final cart = CartController();
    await tester.pumpWidget(
      _wrap(
        _catalogue,
        auth: AuthController(const MockAuthRepository(latency: Duration.zero)),
        cart: cart,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle).first);
    await tester.pumpAndSettle();

    // Modale affichée, rien ajouté au panier.
    expect(find.text('Connexion requise'), findsOneWidget);
    expect(cart.isEmpty, isTrue);
  });

  testWidgets('Connecté : ajout au panier fonctionne (pas de mur)', (
    tester,
  ) async {
    final auth = AuthController(
      const MockAuthRepository(latency: Duration.zero),
    );
    await tester.runAsync(() => auth.login('etudiant@sup2i.ma', 'secret12'));
    final cart = CartController();

    await tester.pumpWidget(_wrap(_catalogue, auth: auth, cart: cart));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle).first);
    await tester.pumpAndSettle();

    // Pas de mur ; le « + » ouvre la feuille de personnalisation avec options.
    expect(find.text('Connexion requise'), findsNothing);
    expect(cart.isEmpty, isTrue); // rien ajouté tant qu'on n'a pas confirmé
    expect(find.text('Frites'), findsOneWidget); // option « add frites »

    // Confirmer dans la feuille ajoute réellement au panier.
    await tester.tap(find.textContaining('Ajouter au panier'));
    await tester.pumpAndSettle();
    expect(cart.isEmpty, isFalse);
  });
}
