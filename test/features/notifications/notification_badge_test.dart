import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/app/notifications_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/core/widgets/badged_icon_button.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/cart/presentation/widgets/cart_button.dart';
import 'package:sup2i_food_mobile/features/notifications/application/notifications_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/data/notifications_repository.dart';
import 'package:sup2i_food_mobile/features/notifications/domain/app_notification.dart';
import 'package:sup2i_food_mobile/features/notifications/presentation/widgets/notification_button.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

class _FakeNotifs implements NotificationsRepository {
  _FakeNotifs(this.items);
  final List<AppNotification> items;

  @override
  Future<List<AppNotification>> list() async => items;

  @override
  Future<Map<NotificationCategory, bool>> preferences() async => const {};

  @override
  Future<void> setPreference(NotificationCategory c, bool e) async {}
}

AppNotification _notif(String id, {required bool read}) => AppNotification(
  id: id,
  type: NotificationType.generic,
  title: 't',
  body: 'b',
  timeLabel: 'now',
  read: read,
);

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('fr'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(appBar: AppBar(actions: [child])),
);

void main() {
  testWidgets('BadgedIconButton : pas de badge si count = 0', (tester) async {
    await tester.pumpWidget(
      _app(
        BadgedIconButton(
          icon: Icons.notifications_none,
          count: 0,
          onPressed: () {},
          semanticLabel: 'x',
        ),
      ),
    );
    expect(find.text('0'), findsNothing);
  });

  testWidgets('BadgedIconButton : badge numérique si count > 0', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        BadgedIconButton(
          icon: Icons.notifications_none,
          count: 3,
          onPressed: () {},
          semanticLabel: 'x',
        ),
      ),
    );
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('Cloche : badge affiché quand des non-lues existent', (
    tester,
  ) async {
    final ctrl = NotificationsController(
      _FakeNotifs([_notif('a', read: false), _notif('b', read: false)]),
    )..load();
    await tester.pumpWidget(
      NotificationsScope(
        controller: ctrl,
        child: _app(const NotificationButton()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Cloche : pas de badge si tout est lu', (tester) async {
    final ctrl = NotificationsController(_FakeNotifs([_notif('a', read: true)]))
      ..load();
    await tester.pumpWidget(
      NotificationsScope(
        controller: ctrl,
        child: _app(const NotificationButton()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('1'), findsNothing);
  });

  testWidgets('Panier : badge apparaît selon le nombre d\'articles', (
    tester,
  ) async {
    final cart = CartController();
    await tester.pumpWidget(
      CartScope(controller: cart, child: _app(const CartButton())),
    );
    await tester.pumpAndSettle();
    expect(find.text('1'), findsNothing); // panier vide -> pas de badge

    cart.addItem(productId: 'p1', name: 'Tacos', unitPriceCents: 4000);
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });
}
