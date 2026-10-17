import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/app_shell.dart';
import 'package:sup2i_food_mobile/app/auth_scope.dart';
import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/favorites_scope.dart';
import 'package:sup2i_food_mobile/app/notifications_scope.dart';
import 'package:sup2i_food_mobile/app/orders_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_colors.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/auth/application/auth_controller.dart';
import 'package:sup2i_food_mobile/features/auth/data/mock_auth_repository.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/favorites/application/favorites_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/application/notifications_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/data/notifications_repository.dart';
import 'package:sup2i_food_mobile/features/orders/data/mock_order_repository.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home, {required AuthController auth}) {
  return AuthScope(
    controller: auth,
    child: CartScope(
      controller: CartController(),
      child: OrdersScope(
        repository: MockOrderRepository(latency: Duration.zero),
        child: FavoritesScope(
          controller: FavoritesController(),
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
        ),
      ),
    ),
  );
}

Future<AuthController> _authenticatedController(WidgetTester tester) async {
  final auth = AuthController(const MockAuthRepository(latency: Duration.zero));

  await tester.runAsync(() => auth.login('etudiant@sup2i.ma', 'secret12'));

  return auth;
}

void main() {
  testWidgets('Le shell final affiche Accueil Snack Commandes Cantine Profil', (
    tester,
  ) async {
    final auth = await _authenticatedController(tester);

    await tester.pumpWidget(_wrap(const AppShell(), auth: auth));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('main_bottom_navigation')), findsOneWidget);

    for (final label in const <String>[
      'Accueil',
      'Snack',
      'Commandes',
      'Cantine',
      'Profil',
    ]) {
      expect(find.text(label), findsWidgets);
    }

    final theme = Theme.of(tester.element(find.byType(NavigationBar)));

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.blue600);
    expect(theme.colorScheme.secondary, AppColors.pink600);

    auth.dispose();
  });

  testWidgets('Accueil final expose header, hero et étudiant authentifié', (
    tester,
  ) async {
    final auth = await _authenticatedController(tester);

    await tester.pumpWidget(_wrap(const AppShell(), auth: auth));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_brand_header')), findsOneWidget);
    expect(find.byKey(const Key('home_hero_banner')), findsOneWidget);
    expect(find.byKey(const Key('home_search')), findsOneWidget);
    expect(find.text('Bien manger.\nMieux étudier.'), findsOneWidget);
    expect(find.byKey(const Key('home_student_name')), findsOneWidget);

    auth.dispose();
  });

  testWidgets('Navigation authentifiée ouvre la Cantine', (tester) async {
    final auth = await _authenticatedController(tester);

    await tester.pumpWidget(_wrap(const AppShell(), auth: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cantine'));
    await tester.pumpAndSettle();

    expect(find.text('Votre Food Pass'), findsOneWidget);

    auth.dispose();
  });
}
