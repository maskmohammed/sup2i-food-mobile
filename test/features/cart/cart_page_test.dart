import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/cart/domain/time_slot.dart';
import 'package:sup2i_food_mobile/features/cart/presentation/cart_page.dart';
import 'package:sup2i_food_mobile/features/catalogue/presentation/widgets/product_image.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(CartController cart, Widget home) => CartScope(
  controller: cart,
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  ),
);

void main() {
  testWidgets('Panier vide : etat vide + CTA', (tester) async {
    await tester.pumpWidget(_wrap(CartController(), const CartPage()));
    await tester.pumpAndSettle();

    expect(find.text('Votre panier est vide'), findsOneWidget);
    expect(
      find.text(AppLocalizations(const Locale('fr')).discoverMenu),
      findsOneWidget,
    );
  });

  testWidgets('Panier rempli : ligne, total, CTA desactive sans creneau', (
    tester,
  ) async {
    final cart = CartController()
      ..addItem(
        productId: 'p1',
        name: 'Tacos Poulet XL',
        unitPriceCents: 4000,
        quantity: 2,
      );

    await tester.pumpWidget(_wrap(cart, const CartPage()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cart_screen')), findsOneWidget);
    expect(find.text('Tacos Poulet XL'), findsOneWidget);
    expect(find.byType(ProductImage), findsOneWidget);
    expect(find.text('80,00 DH'), findsWidgets);

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('cart_checkout')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Taper une ligne edite sans dupliquer', (tester) async {
    final cart = CartController()
      ..addItem(
        productId: 'p1',
        name: 'Tacos Poulet XL',
        unitPriceCents: 4000,
        quantity: 2,
      );

    await tester.pumpWidget(_wrap(cart, const CartPage()));
    await tester.pumpAndSettle();

    expect(cart.lines, hasLength(1));

    await tester.tap(find.text('Tacos Poulet XL'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product_options_confirm')), findsOneWidget);

    await tester.tap(find.byKey(const Key('product_options_confirm')));
    await tester.pumpAndSettle();

    expect(cart.lines, hasLength(1));
  });

  testWidgets('Creneau choisi : CTA Commander actif', (tester) async {
    final cart = CartController()
      ..addItem(productId: 'p1', name: 'Tacos', unitPriceCents: 4000)
      ..selectSlot(
        const TimeSlot(id: 's1', label: '12h00', status: SlotStatus.available),
      );

    await tester.pumpWidget(_wrap(cart, const CartPage()));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('cart_checkout')),
    );
    expect(button.onPressed, isNotNull);
  });
}
