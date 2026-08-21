import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/core/theme/app_theme.dart';
import 'package:sup2i_food_mobile/features/rewards/application/rewards_controller.dart';
import 'package:sup2i_food_mobile/features/rewards/data/rewards_repository.dart';
import 'package:sup2i_food_mobile/features/rewards/presentation/rewards_pages.dart';
import 'package:sup2i_food_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget home) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('fr'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: home,
);

const _repo = MockRewardsRepository(latency: Duration.zero);

void main() {
  test('RewardsController : promotions et fidélité', () async {
    final c = RewardsController(_repo);
    await c.loadPromotions();
    expect(c.promotions.length, 2);
    await c.loadLoyalty();
    expect(c.loyalty!.points, 240);
    expect(c.history.length, 3);
  });

  testWidgets('Promotions : liste des offres', (tester) async {
    await tester.pumpWidget(_wrap(const PromotionsPage(repository: _repo)));
    await tester.pumpAndSettle();

    expect(find.text('Menu étudiant -20%'), findsOneWidget);
    expect(find.text('-20%'), findsOneWidget);
  });

  testWidgets('Fidélité : solde et historique', (tester) async {
    await tester.pumpWidget(_wrap(const LoyaltyPage(repository: _repo)));
    await tester.pumpAndSettle();

    expect(find.text('240'), findsOneWidget);
    expect(find.text('Commande #A1949'), findsOneWidget);
  });
}
