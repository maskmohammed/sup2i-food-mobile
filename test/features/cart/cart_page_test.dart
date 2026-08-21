import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/cart/domain/time_slot.dart';
import 'package:sup2i_food_mobile/features/cart/presentation/cart_page.dart';
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
  testWidgets('Panier vide : état vide + CTA', (tester) async {
    await tester.pumpWidget(_wrap(CartController(), const CartPage()));
    await tester.pumpAndSettle();

    expect(find.text('Votre panier est vide'), findsOneWidget);
    expect(find.text('Découvrir le menu'), findsOneWidget);
  });

  testWidgets(
    'Panier rempli : ligne, total, Commander désactivé sans créneau',
    (tester) async {
      final cart = CartController()
        ..addItem(
          productId: 'p1',
          name: 'Tacos Poulet XL',
          unitPriceCents: 4000,
          quantity: 2,
        );

      await tester.pumpWidget(_wrap(cart, const CartPage()));
      await tester.pumpAndSettle();

      expect(find.text('Tacos Poulet XL'), findsOneWidget);
      // Sous-total indicatif = 2 × 40,00 DH.
      expect(find.text('80,00 DH'), findsWidgets);

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Commander'),
      );
      expect(button.onPressed, isNull);
    },
  );

  testWidgets('Créneau choisi : Commander activé', (tester) async {
    final cart = CartController()
      ..addItem(productId: 'p1', name: 'Tacos', unitPriceCents: 4000)
      ..selectSlot(
        const TimeSlot(id: 's1', label: '12h00', status: SlotStatus.available),
      );

    await tester.pumpWidget(_wrap(cart, const CartPage()));
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Commander'),
    );
    expect(button.onPressed, isNotNull);
  });
}
