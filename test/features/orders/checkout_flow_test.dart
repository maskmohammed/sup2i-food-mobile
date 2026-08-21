import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/orders_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/cart/domain/time_slot.dart';
import 'package:sup2i_food_mobile/features/cart/presentation/cart_page.dart';
import 'package:sup2i_food_mobile/features/orders/data/mock_order_repository.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

void main() {
  testWidgets('Commander : paiement → commande créée → suivi, panier vidé', (
    tester,
  ) async {
    final cart = CartController()
      ..addItem(productId: 'p1', name: 'Tacos', unitPriceCents: 4000)
      ..selectSlot(
        const TimeSlot(id: 's1', label: '12h00', status: SlotStatus.available),
      );
    final repo = MockOrderRepository(latency: Duration.zero);

    await tester.pumpWidget(
      CartScope(
        controller: cart,
        child: OrdersScope(
          repository: repo,
          child: MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('fr'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const CartPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Commander'));
    await tester.pumpAndSettle();
    expect(find.text('Paiement'), findsOneWidget);

    await tester.tap(find.text('Confirmer la commande'));
    await tester.pumpAndSettle();

    // Écran de suivi : statut en attente de paiement.
    expect(find.text('En attente de paiement'), findsOneWidget);
    expect(cart.isEmpty, isTrue);
  });
}
