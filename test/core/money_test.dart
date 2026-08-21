import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/core/format/money.dart';

void main() {
  test('Format DH : virgule, 2 décimales, suffixe DH', () {
    expect(Money.format(4000), '40,00 DH');
    expect(Money.format(2500), '25,00 DH');
    expect(Money.format(720), '7,20 DH');
    expect(Money.format(500), '5,00 DH');
    expect(Money.format(9000), '90,00 DH');
    expect(Money.format(0), '0,00 DH');
  });
}
