import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/auth_scope.dart';
import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/orders_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/auth/application/auth_controller.dart';
import 'package:sup2i_food_mobile/features/auth/data/mock_auth_repository.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/cart/domain/time_slot.dart';
import 'package:sup2i_food_mobile/features/cart/presentation/cart_page.dart';
import 'package:sup2i_food_mobile/features/orders/data/mock_order_repository.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

void main() {
  testWidgets('Commander : paiement -> confirmation -> suivi, panier vide', (
    tester,
  ) async {
    final cart = CartController()
      ..addItem(productId: 'p1', name: 'Tacos', unitPriceCents: 4000)
      ..selectSlot(
        const TimeSlot(id: 's1', label: '12h00', status: SlotStatus.available),
      );

    final repo = MockOrderRepository(latency: Duration.zero);
    final auth = AuthController(
      const MockAuthRepository(latency: Duration.zero),
    );

    await tester.runAsync(() => auth.login('etudiant@sup2i.ma', 'secret12'));

    await tester.pumpWidget(
      AuthScope(
        controller: auth,
        child: CartScope(
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
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cart_checkout')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('payment_method_sheet')), findsOneWidget);

    await tester.tap(find.byKey(const Key('payment_confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('order_confirmation_screen')), findsOneWidget);
    expect(find.text('Commande confirmee !'), findsOneWidget);
    expect(cart.isEmpty, isTrue);

    await tester.tap(find.byKey(const Key('confirmation_track')));
    await tester.pumpAndSettle();

    expect(find.text('En attente de paiement'), findsOneWidget);

    auth.dispose();
  });
}
