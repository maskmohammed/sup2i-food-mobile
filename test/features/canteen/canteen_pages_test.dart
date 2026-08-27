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

void main() {
  testWidgets('Cantine : menu de la semaine + accès Food Pass / abonnement', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CanteenPage(repository: _repo)));
    await tester.pumpAndSettle();

    expect(find.text('Plat Lundi'), findsOneWidget);
    expect(find.text('Votre Food Pass'), findsOneWidget);
    expect(find.text('Mon abonnement Cantine'), findsOneWidget);
  });

  testWidgets('Food Pass : identité et statut Active', (tester) async {
    await tester.pumpWidget(_wrap(const FoodPassPage(repository: _repo)));
    await tester.pumpAndSettle();

    expect(find.text('Chnaf Yahya'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('ID : 12345678'), findsOneWidget);
  });

  testWidgets('Abonnement : plan actif et quota 8/12', (tester) async {
    await tester.pumpWidget(_wrap(const SubscriptionPage(repository: _repo)));
    await tester.pumpAndSettle();

    expect(find.text('Plan Étudiant Standard'), findsOneWidget);
    expect(find.text('Actif'), findsOneWidget);
    expect(find.text('8 / 12'), findsOneWidget);
  });

  testWidgets('Réserver un plat → confirmation', (tester) async {
    await tester.pumpWidget(_wrap(const CanteenPage(repository: _repo)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plat Lundi'));
    await tester.pumpAndSettle();

    expect(find.text('Réservation confirmée'), findsWidgets);
    expect(find.text('Annuler la réservation'), findsOneWidget);
    expect(find.text('Retour à la cantine'), findsOneWidget);
  });

  testWidgets('Food Pass → déclarer la perte', (tester) async {
    await tester.pumpWidget(_wrap(const FoodPassPage(repository: _repo)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Déclarer la perte'));
    await tester.pumpAndSettle();

    expect(find.text('Action irréversible'), findsOneWidget);
    expect(find.text('Carte perdue'), findsOneWidget);
    expect(find.text('Confirmer la perte'), findsOneWidget);
  });
}
