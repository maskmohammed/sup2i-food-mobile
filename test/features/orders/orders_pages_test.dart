import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/notifications_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/cart/domain/cart_line.dart';
import 'package:sup2i_food_mobile/features/notifications/application/notifications_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/data/notifications_repository.dart';
import 'package:sup2i_food_mobile/features/orders/data/mock_order_repository.dart';
import 'package:sup2i_food_mobile/features/orders/domain/order.dart';
import 'package:sup2i_food_mobile/features/orders/presentation/order_tracking_page.dart';
import 'package:sup2i_food_mobile/features/orders/presentation/orders_list_page.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home) => CartScope(
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
);

Future<void> _scrollUntilBuilt(WidgetTester tester, Finder target) async {
  for (var index = 0; index < 12 && target.evaluate().isEmpty; index++) {
    final scrollable = find.byType(Scrollable).last;
    await tester.drag(scrollable, const Offset(0, -220));
    await tester.pump();
  }

  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Historique final : filtres et commandes', (tester) async {
    final repo = MockOrderRepository(latency: Duration.zero);

    await tester.pumpWidget(_wrap(OrdersListPage(repository: repo)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('orders_screen')), findsOneWidget);
    expect(find.byKey(const Key('orders_filters')), findsOneWidget);
    expect(find.text('En cours'), findsOneWidget);
    expect(find.textContaining('Termin'), findsOneWidget);
    expect(find.text('Annulées'), findsOneWidget);

    await tester.tap(find.textContaining('Termin'));
    await tester.pumpAndSettle();

    expect(find.text('Commande #A1949'), findsOneWidget);
    expect(find.text('Retirée'), findsOneWidget);

    await tester.tap(find.text('Annulées'));
    await tester.pumpAndSettle();

    expect(find.text('Annulée'), findsOneWidget);
  });

  testWidgets('Suivi attente : QR, timeline et annulation', (tester) async {
    final repo = MockOrderRepository(latency: Duration.zero);

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

    expect(find.byKey(const Key('order_tracking_screen')), findsOneWidget);
    expect(find.byKey(const Key('tracking_qr_card')), findsOneWidget);
    // V9 timeline materialization
    await _scrollUntilBuilt(tester, find.byKey(const Key('tracking_timeline')));
    expect(find.byKey(const Key('tracking_timeline')), findsOneWidget);
    expect(find.byKey(const Key('tracking_qr_card')), findsOneWidget);
    expect(find.text('En attente de paiement'), findsWidgets);
    expect(find.text('Paiement confirmé', skipOffstage: false), findsOneWidget);
    // V9 cancel materialization
    await _scrollUntilBuilt(tester, find.byKey(const Key('order_cancel')));
    expect(
      find.byKey(const Key('order_cancel'), skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('Suivi commande retiree : annulation absente', (tester) async {
    final repo = MockOrderRepository(latency: Duration.zero);

    await tester.pumpWidget(
      _wrap(OrderTrackingPage(orderId: 'o_a1949', repository: repo)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retirée'), findsWidgets);
    expect(find.byKey(const Key('order_cancel')), findsNothing);
  });

  testWidgets('Suivi READY : banniere et ouverture plein ecran', (
    tester,
  ) async {
    final repo = MockOrderRepository(latency: Duration.zero);

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

    await tester.runAsync(() async {
      for (var index = 0; index < 5; index++) {
        await repo.getOrder(order.id);
      }
    });

    await tester.pumpWidget(
      _wrap(OrderTrackingPage(orderId: order.id, repository: repo)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tracking_ready_banner')), findsOneWidget);
    expect(find.text('Votre commande est prête !'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tracking_ready_banner')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('commande est pr'), findsOneWidget);
  });
}
