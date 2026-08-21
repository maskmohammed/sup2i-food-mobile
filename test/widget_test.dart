// Smoke test du shell : bottom nav 5 onglets, thème appliqué, navigation.
// Le shell est monté isolément (l'écran d'entrée de l'app est Login via AuthGate).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/app_shell.dart';
import 'package:sup2i_food_mobile/app/auth_scope.dart';
import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/orders_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_colors.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/auth/application/auth_controller.dart';
import 'package:sup2i_food_mobile/features/auth/data/mock_auth_repository.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/orders/data/mock_order_repository.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home) => AuthScope(
  controller: AuthController(const MockAuthRepository(latency: Duration.zero)),
  child: CartScope(
    controller: CartController(),
    child: OrdersScope(
      repository: MockOrderRepository(latency: Duration.zero),
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: home,
      ),
    ),
  ),
);

void main() {
  testWidgets('Le shell affiche la bottom nav 5 onglets', (tester) async {
    await tester.pumpWidget(_wrap(const AppShell()));
    // L'onglet Commander (catalogue) déclenche un chargement asynchrone :
    // on le laisse se terminer pour éviter un timer en attente.
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in const [
      'Accueil',
      'Commander',
      'Cantine',
      'Commandes',
      'Profil',
    ]) {
      expect(find.text(label), findsWidgets);
    }

    final theme = Theme.of(tester.element(find.byType(NavigationBar)));
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.navy900);
  });

  testWidgets('La sélection d\'un onglet change l\'écran affiché', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const AppShell()));

    await tester.tap(find.text('Cantine'));
    await tester.pumpAndSettle();

    expect(find.text('Cantine et Food Pass — à venir (M8).'), findsOneWidget);
  });
}
