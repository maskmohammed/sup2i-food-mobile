import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/domain/cart_line.dart';
import 'package:sup2i_food_mobile/features/orders/data/mock_order_repository.dart';
import 'package:sup2i_food_mobile/features/orders/domain/order.dart';
import 'package:sup2i_food_mobile/features/orders/presentation/order_tracking_page.dart';
import 'package:sup2i_food_mobile/features/orders/presentation/orders_list_page.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('fr'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: home,
);

void main() {
  testWidgets('Historique : commandes avec statuts', (tester) async {
    final repo = MockOrderRepository(latency: Duration.zero);
    await tester.pumpWidget(_wrap(OrdersListPage(repository: repo)));
    await tester.pumpAndSettle();

    expect(find.text('Commande #A1949'), findsOneWidget);
    expect(find.text('Retirée'), findsOneWidget);
    expect(find.text('Annulée'), findsOneWidget);
  });

  testWidgets('Suivi : commande en attente → QR, timeline, annulation', (
    tester,
  ) async {
    final repo = MockOrderRepository(latency: Duration.zero);
    // `Future.delayed` ne se résout pas dans le corps d'un testWidgets sans
    // pump ; on force la vraie async pour créer la commande hors-widget.
    final order = (await tester.runAsync(
      () => repo.createOrder(
        lines: const <CartLine>[
          CartLine(
            id: 'p1|',
            productId: 'p1',
            name: 'Tacos',
            unitPriceCents: 4000,
            quantity: 1,
          ),
        ],
        slotLabel: '12h00',
        paymentMethod: PaymentMethod.cash,
      ),
    ))!;

    await tester.pumpWidget(
      _wrap(OrderTrackingPage(orderId: order.id, repository: repo)),
    );
    await tester.pumpAndSettle();

    expect(find.text(order.number), findsOneWidget);
    expect(find.text('En attente de paiement'), findsOneWidget);
    // Timeline + bouton d'annulation peuvent être sous la ligne de flottaison
    // (ListView) : on vérifie leur présence dans l'arbre, offstage inclus.
    expect(find.text('Paiement confirmé', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Annuler la commande', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('Suivi : commande retirée → pas d\'annulation', (tester) async {
    final repo = MockOrderRepository(latency: Duration.zero);
    await tester.pumpWidget(
      _wrap(OrderTrackingPage(orderId: 'o_a1949', repository: repo)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retirée'), findsOneWidget);
    expect(find.text('Annuler la commande'), findsNothing);
  });
}
