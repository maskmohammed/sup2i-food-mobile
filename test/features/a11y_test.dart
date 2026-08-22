import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/canteen/data/canteen_repository.dart';
import 'package:sup2i_food_mobile/features/canteen/presentation/food_pass_page.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/cart/presentation/cart_page.dart';
import 'package:sup2i_food_mobile/features/orders/data/mock_order_repository.dart';
import 'package:sup2i_food_mobile/features/orders/presentation/order_tracking_page.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home, {CartController? cart}) => CartScope(
  controller: cart ?? CartController(),
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  ),
);

void main() {
  testWidgets('Food Pass : QR annoncé au lecteur d\'écran', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        const FoodPassPage(
          repository: MockCanteenRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Code QR du Food Pass'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('Commande QR : QR annoncé avec le numéro', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        OrderTrackingPage(
          orderId: 'o_a1949',
          repository: MockOrderRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Code QR de retrait de la commande A1949'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('Panier : boutons quantité avec tooltips', (tester) async {
    final cart = CartController()
      ..addItem(
        productId: 'p1',
        name: 'Tacos Poulet XL',
        unitPriceCents: 4000,
        quantity: 2,
      );
    await tester.pumpWidget(_wrap(const CartPage(), cart: cart));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Augmenter la quantité'), findsOneWidget);
    expect(find.byTooltip('Diminuer la quantité'), findsOneWidget);
  });
}
