import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/core/error/api_codes.dart';
import 'package:sup2i_food_mobile/features/catalogue/application/product_detail_controller.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/mock_catalogue_repository.dart';

void main() {
  ProductDetailController controller() => ProductDetailController(
    const MockCatalogueRepository(latency: Duration.zero),
  );

  test('load : fiche tacos avec options et durée', () async {
    final c = controller();
    await c.load('p1');
    expect(c.detail, isNotNull);
    expect(c.detail!.optionGroups, isNotEmpty);
    expect(c.detail!.prepMinutes, 15);
    expect(c.errorCode, isNull);
  });

  test('load : id inconnu → PRODUCT_UNAVAILABLE', () async {
    final c = controller();
    await c.load('inconnu');
    expect(c.detail, isNull);
    expect(c.errorCode, ApiCodes.productUnavailable);
  });

  test('quantité : incrément / décrément, minimum 1', () {
    final c = controller();
    expect(c.quantity, 1);
    c.decrement();
    expect(c.quantity, 1);
    c.increment();
    c.increment();
    expect(c.quantity, 3);
    c.decrement();
    expect(c.quantity, 2);
  });

  test('toggleOption : ajoute puis retire', () {
    final c = controller();
    expect(c.isSelected('frites'), isFalse);
    c.toggleOption('frites');
    expect(c.isSelected('frites'), isTrue);
    c.toggleOption('frites');
    expect(c.isSelected('frites'), isFalse);
  });
}
