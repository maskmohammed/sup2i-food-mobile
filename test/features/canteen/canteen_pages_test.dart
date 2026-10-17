import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/notifications_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/canteen/data/canteen_repository.dart';
import 'package:sup2i_food_mobile/features/canteen/presentation/canteen_page.dart';
import 'package:sup2i_food_mobile/features/canteen/presentation/food_pass_page.dart';
import 'package:sup2i_food_mobile/features/canteen/presentation/subscription_page.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/application/notifications_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/data/notifications_repository.dart';
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

const _repo = MockCanteenRepository(latency: Duration.zero);

Future<void> _dragUntilBuilt(WidgetTester tester, Finder target) async {
  for (var index = 0; index < 10 && target.evaluate().isEmpty; index++) {
    final scrollable = find.byType(Scrollable).last;
    await tester.drag(scrollable, const Offset(0, -260));
    await tester.pump();
  }

  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Cantine finale : hero, pass, abonnement et menu', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CanteenPage(repository: _repo)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('canteen_screen')), findsOneWidget);
    expect(find.byKey(const Key('canteen_hero')), findsOneWidget);
    expect(find.byKey(const Key('canteen_food_pass')), findsOneWidget);
    expect(find.byKey(const Key('canteen_subscription')), findsOneWidget);
    expect(find.text('Plat Lundi'), findsOneWidget);
  });

  testWidgets('Food Pass final : identite, statut et QR', (tester) async {
    await tester.pumpWidget(_wrap(const FoodPassPage(repository: _repo)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('food_pass_screen')), findsOneWidget);
    expect(find.byKey(const Key('food_pass_card')), findsOneWidget);
    expect(find.byKey(const Key('food_pass_qr')), findsOneWidget);
    expect(find.text('Chnaf Yahya'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('ID : 12345678'), findsOneWidget);
  });

  testWidgets('Abonnement final : plan actif et quota serveur', (tester) async {
    await tester.pumpWidget(_wrap(const SubscriptionPage(repository: _repo)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('subscription_screen')), findsOneWidget);
    expect(find.byKey(const Key('subscription_card')), findsOneWidget);
    expect(find.byKey(const Key('subscription_quota')), findsOneWidget);
    expect(find.text('Plan Etudiant Standard'), findsNothing);
    expect(find.text('Plan Étudiant Standard'), findsOneWidget);
    expect(find.text('Actif'), findsOneWidget);
    expect(find.text('8 / 12'), findsOneWidget);
  });

  testWidgets('Reservation : confirmation finale', (tester) async {
    await tester.pumpWidget(_wrap(const CanteenPage(repository: _repo)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plat Lundi'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('reservation_confirmed_screen')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('reservation_summary')), findsOneWidget);
    expect(find.byKey(const Key('reservation_cancel')), findsOneWidget);
    // V7 reservation scroll
    await _dragUntilBuilt(tester, find.byKey(const Key('reservation_back')));
    expect(find.byKey(const Key('reservation_back')), findsOneWidget);
  });

  testWidgets('Food Pass : declaration de perte', (tester) async {
    await tester.pumpWidget(_wrap(const FoodPassPage(repository: _repo)));
    await tester.pumpAndSettle();

    // V7 loss scroll
    await _dragUntilBuilt(tester, find.byKey(const Key('declare_loss')));
    await tester.tap(find.byKey(const Key('declare_loss')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loss_screen')), findsOneWidget);
    expect(find.byKey(const Key('loss_warning')), findsOneWidget);
    expect(find.byKey(const Key('loss_confirm')), findsOneWidget);
    expect(find.text('Carte perdue'), findsOneWidget);
  });
}
