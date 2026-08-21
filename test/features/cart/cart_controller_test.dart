import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/features/cart/application/cart_controller.dart';
import 'package:sup2i_food_mobile/features/cart/domain/time_slot.dart';

void main() {
  test('addItem : fusionne les lignes identiques, cumule la quantité', () {
    final cart = CartController();
    cart.addItem(productId: 'p1', name: 'Tacos', unitPriceCents: 4000);
    cart.addItem(
      productId: 'p1',
      name: 'Tacos',
      unitPriceCents: 4000,
      quantity: 2,
    );
    expect(cart.lines.length, 1);
    expect(cart.itemCount, 3);
    expect(cart.subtotalCents, 12000);
  });

  test('options différentes : lignes distinctes', () {
    final cart = CartController();
    cart.addItem(productId: 'p1', name: 'Tacos', unitPriceCents: 4000);
    cart.addItem(
      productId: 'p1',
      name: 'Tacos',
      unitPriceCents: 4300,
      optionsLabel: 'Fromage',
    );
    expect(cart.lines.length, 2);
  });

  test('decrement à 0 retire la ligne', () {
    final cart = CartController();
    cart.addItem(productId: 'p1', name: 'Tacos', unitPriceCents: 4000);
    final id = cart.lines.first.id;
    cart.decrement(id);
    expect(cart.isEmpty, isTrue);
  });

  test('selectSlot et clear', () {
    final cart = CartController();
    cart.addItem(productId: 'p1', name: 'Tacos', unitPriceCents: 4000);
    cart.selectSlot(
      const TimeSlot(id: 's1', label: '12h', status: SlotStatus.available),
    );
    expect(cart.slot, isNotNull);
    cart.clear();
    expect(cart.isEmpty, isTrue);
    expect(cart.slot, isNull);
  });
}
