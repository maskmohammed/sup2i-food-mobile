import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/app/cart_scope.dart';
import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/cart/data/slot_repository.dart';
import 'package:sup2i_food_mobile/features/cart/presentation/slot_page.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home) => CartScope(
  controller: CartController(),
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  ),
);

void main() {
  testWidgets('Affiche les creneaux et leurs etats serveur', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SlotPage(repository: MockSlotRepository(latency: Duration.zero)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('slot_screen')), findsOneWidget);
    expect(find.byKey(const Key('slot_list')), findsOneWidget);
    expect(find.text('12h00 - 12h15'), findsOneWidget);
    expect(find.text('Disponible'), findsWidgets);
    expect(find.text('Presque complet'), findsOneWidget);
    expect(find.text('Complet'), findsOneWidget);
  });
}
