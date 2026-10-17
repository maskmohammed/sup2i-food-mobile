import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/core/theme/app_motion.dart';

void main() {
  test('durées conformes à la charte', () {
    expect(AppMotion.ui.inMilliseconds, inInclusiveRange(160, 220));
    expect(AppMotion.uiFast.inMilliseconds, inInclusiveRange(160, 220));
    expect(AppMotion.pulse.inMilliseconds, inInclusiveRange(250, 400));
    expect(AppMotion.cartAdd.inMilliseconds, inInclusiveRange(160, 200));
  });

  testWidgets('reduceMotion + effective suivent MediaQuery.disableAnimations', (
    tester,
  ) async {
    late BuildContext reduced;
    late BuildContext normal;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            reduced = context;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(AppMotion.reduceMotion(reduced), isTrue);
    expect(AppMotion.effective(reduced, AppMotion.pulse), Duration.zero);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Builder(
          builder: (context) {
            normal = context;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(AppMotion.reduceMotion(normal), isFalse);
    expect(AppMotion.effective(normal, AppMotion.pulse), AppMotion.pulse);
  });
}
