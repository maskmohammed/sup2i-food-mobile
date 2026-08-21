import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/features/catalogue/application/catalogue_controller.dart';
import 'package:sup2i_food_mobile/features/catalogue/data/mock_catalogue_repository.dart';

void main() {
  CatalogueController controller() => CatalogueController(
    const MockCatalogueRepository(latency: Duration.zero),
  );

  test('load : catégories et produits chargés, sans erreur', () async {
    final c = controller();
    await c.load();
    expect(c.categories, isNotEmpty);
    expect(c.products.length, 5);
    expect(c.errorCode, isNull);
    expect(c.isLoading, isFalse);
  });

  test('selectCategory : filtre les produits', () async {
    final c = controller();
    await c.load();
    await c.selectCategory('pizza');
    expect(c.selectedCategoryId, 'pizza');
    expect(c.products, isNotEmpty);
    expect(c.products.every((p) => p.categoryId == 'pizza'), isTrue);
  });

  test('selectCategory(null) : revient à tous', () async {
    final c = controller();
    await c.load();
    await c.selectCategory('pizza');
    await c.selectCategory(null);
    expect(c.products.length, 5);
  });
}
