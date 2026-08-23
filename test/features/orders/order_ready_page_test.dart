import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/features/orders/domain/order.dart';
import 'package:sup2i_food_mobile/features/orders/presentation/order_ready_page.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Order _readyOrder() => Order(
  id: 'o_ready',
  number: 'A-2048',
  status: OrderStatus.ready,
  lines: const [],
  totalCents: 4000,
  createdAt: DateTime(2026, 8, 22, 12),
);

Widget _wrap(Widget home) => MaterialApp(
  locale: const Locale('fr'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: home,
);

void main() {
  testWidgets('affiche titre, numéro et QR de retrait', (tester) async {
    await tester.pumpWidget(_wrap(OrderReadyPage(order: _readyOrder())));
    await tester.pumpAndSettle();

    expect(find.text('Votre commande est prête !'), findsOneWidget);
    expect(find.text('A-2048'), findsOneWidget);
  });

  testWidgets('le bouton Fermer referme l\'écran', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) => OrderReadyPage(order: _readyOrder()),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Votre commande est prête !'), findsOneWidget);

    // Bouton plein largeur "Fermer" en bas de l'écran.
    await tester.tap(find.widgetWithText(FilledButton, 'Fermer'));
    await tester.pumpAndSettle();
    expect(find.text('Votre commande est prête !'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });
}
