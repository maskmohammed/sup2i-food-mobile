import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/notifications/data/notifications_repository.dart';
import 'package:sup2i_food_mobile/features/notifications/presentation/notifications_page.dart';
import 'package:sup2i_food_mobile/features/notifications/presentation/preferences_page.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('fr'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: home,
);

void main() {
  testWidgets('Notifications finales : liste et cartes', (tester) async {
    await tester.pumpWidget(
      _wrap(
        NotificationsPage(
          repository: MockNotificationsRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('notifications_screen')), findsOneWidget);
    expect(find.byKey(const Key('notifications_list')), findsOneWidget);
    expect(find.byKey(const Key('notification_card_0')), findsOneWidget);
    expect(find.text('Votre commande est prête'), findsOneWidget);
    expect(find.text('Paiement confirmé'), findsOneWidget);
    expect(find.text('Quota faible'), findsOneWidget);
  });

  testWidgets('Preferences finales : categories et switches', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PreferencesPage(
          repository: MockNotificationsRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('preferences_screen')), findsOneWidget);
    expect(find.byKey(const Key('preferences_list')), findsOneWidget);
    expect(find.byKey(const Key('notification_pref_0')), findsOneWidget);
    expect(find.text('Transactionnel'), findsOneWidget);
    expect(find.text('Promotions'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(4));

    await tester.tap(find.byType(Switch).at(2));
    await tester.pumpAndSettle();

    expect(find.byType(Switch), findsNWidgets(4));
  });
}
