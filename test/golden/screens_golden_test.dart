import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/favorites_scope.dart';
import 'package:sup2i_food_mobile/app/orders_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/canteen/data/canteen_repository.dart';
import 'package:sup2i_food_mobile/features/canteen/presentation/food_pass_page.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/cart/presentation/cart_page.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/mock_catalogue_repository.dart';
import 'package:sup2i_food_mobile/features/catalogue/presentation/catalogue_page.dart';
import 'package:sup2i_food_mobile/features/favorites/application/favorites_controller.dart';
import 'package:sup2i_food_mobile/features/home/presentation/home_page.dart';
import 'package:sup2i_food_mobile/features/orders/data/mock_order_repository.dart';
import 'package:sup2i_food_mobile/features/orders/presentation/order_tracking_page.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

const _catalogue = MockCatalogueRepository(latency: Duration.zero);

Widget _app(Widget home, {CartController? cart, MockOrderRepository? orders}) {
  Widget tree = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
  if (orders != null) {
    tree = OrdersScope(repository: orders, child: tree);
  }
  tree = CartScope(
    controller: cart ?? CartController(),
    child: FavoritesScope(controller: FavoritesController(), child: tree),
  );
  return tree;
}

/// Fixe une taille d'écran stable puis pompe jusqu'à repos.
///
/// En test, `google_fonts` retombe sur la police par défaut du harnais, plus
/// large que Montserrat/Inter en production ; on rend donc sur un gabarit
/// généreux (≈ grand téléphone) pour absorber cette différence de métriques et
/// éviter des débordements propres au test.
Future<void> _pump(WidgetTester tester, Widget app) async {
  await tester.binding.setSurfaceSize(const Size(440, 956));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('golden: Accueil', (tester) async {
    await _pump(tester, _app(const HomePage(repository: _catalogue)));
    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('goldens/home.png'),
    );
  }, tags: 'golden');

  testWidgets('golden: Catalogue', (tester) async {
    await _pump(tester, _app(const CataloguePage(repository: _catalogue)));
    await expectLater(
      find.byType(CataloguePage),
      matchesGoldenFile('goldens/catalogue.png'),
    );
  }, tags: 'golden');

  testWidgets('golden: Panier', (tester) async {
    final cart = CartController()
      ..addItem(
        productId: 'p1',
        name: 'Tacos Poulet XL',
        unitPriceCents: 4000,
        quantity: 2,
      )
      ..addItem(productId: 'p16', name: 'Tiramisu', unitPriceCents: 2800);
    await _pump(tester, _app(const CartPage(), cart: cart));
    await expectLater(
      find.byType(CartPage),
      matchesGoldenFile('goldens/cart.png'),
    );
  }, tags: 'golden');

  testWidgets('golden: Commande QR', (tester) async {
    final orders = MockOrderRepository(latency: Duration.zero);
    await _pump(
      tester,
      _app(const OrderTrackingPage(orderId: 'o_a1949'), orders: orders),
    );
    await expectLater(
      find.byType(OrderTrackingPage),
      matchesGoldenFile('goldens/order_qr.png'),
    );
  }, tags: 'golden');

  testWidgets('golden: Food Pass', (tester) async {
    await _pump(
      tester,
      _app(
        const FoodPassPage(
          repository: MockCanteenRepository(latency: Duration.zero),
        ),
      ),
    );
    await expectLater(
      find.byType(FoodPassPage),
      matchesGoldenFile('goldens/food_pass.png'),
    );
  }, tags: 'golden');
}
