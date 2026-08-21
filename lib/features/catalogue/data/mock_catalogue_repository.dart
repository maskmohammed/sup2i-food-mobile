import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../domain/category.dart';
import '../domain/product.dart';
import '../domain/product_detail.dart';
import 'catalogue_repository.dart';

/// Catalogue mock (M3, en attendant le backend). Données inspirées de la
/// maquette, prix au format centimes. Un produit est indisponible pour
/// exercer l'état correspondant.
class MockCatalogueRepository implements CatalogueRepository {
  const MockCatalogueRepository({
    this.latency = const Duration(milliseconds: 300),
  });

  final Duration latency;

  static const List<Category> _categories = <Category>[
    Category(id: 'tacos', name: 'Tacos'),
    Category(id: 'pizza', name: 'Pizza'),
    Category(id: 'pasticio', name: 'Pasticio'),
    Category(id: 'boisson', name: 'Boisson'),
    Category(id: 'dessert', name: 'Dessert'),
  ];

  static const List<Product> _products = <Product>[
    Product(
      id: 'p1',
      name: 'Tacos Poulet XL',
      categoryId: 'tacos',
      priceCents: 4000,
      available: true,
      allergens: <String>['Gluten', 'Lait'],
    ),
    Product(
      id: 'p2',
      name: 'Pizza margherita',
      categoryId: 'pizza',
      priceCents: 2500,
      available: true,
      allergens: <String>['Gluten', 'Lait'],
    ),
    Product(
      id: 'p3',
      name: 'Pasticio bœuf',
      categoryId: 'pasticio',
      priceCents: 4000,
      available: true,
      allergens: <String>['Gluten', 'Œuf'],
    ),
    Product(
      id: 'p4',
      name: 'Cheesecake',
      categoryId: 'dessert',
      priceCents: 2500,
      available: true,
      allergens: <String>['Gluten', 'Lait', 'Œuf'],
    ),
    Product(
      id: 'p5',
      name: 'Jus d\'orange',
      categoryId: 'boisson',
      priceCents: 500,
      available: false,
    ),
  ];

  @override
  Future<List<Category>> categories() async {
    await Future<void>.delayed(latency);
    return _categories;
  }

  @override
  Future<List<Product>> products({String? categoryId}) async {
    await Future<void>.delayed(latency);
    if (categoryId == null) return _products;
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  @override
  Future<ProductDetail> productDetail(String productId) async {
    await Future<void>.delayed(latency);
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw const ApiException(ApiCodes.productUnavailable),
    );

    // Seuls les tacos ont des options dans ce mock (démo du parcours complet).
    if (product.categoryId != 'tacos') {
      return ProductDetail(product: product);
    }
    return ProductDetail(
      product: product,
      prepMinutes: 15,
      note: 'Jusqu\'à 2 sauces incluses, +3,00 DH par sauce supplémentaire.',
      optionGroups: const <ProductOptionGroup>[
        ProductOptionGroup(
          id: 'supplements',
          name: 'Suppléments',
          options: <ProductOption>[
            ProductOption(id: 'fromage', name: 'Fromage', priceDeltaCents: 300),
            ProductOption(
              id: 'algerienne',
              name: 'Sauce algérienne',
              priceDeltaCents: 0,
            ),
            ProductOption(
              id: 'barbecue',
              name: 'Barbecue',
              priceDeltaCents: 300,
            ),
          ],
        ),
        ProductOptionGroup(
          id: 'accompagnement',
          name: 'Accompagnement',
          options: <ProductOption>[
            ProductOption(id: 'frites', name: 'Frites', priceDeltaCents: 500),
            ProductOption(
              id: 'gratine',
              name: 'Gratiné',
              priceDeltaCents: 1000,
            ),
          ],
        ),
        ProductOptionGroup(
          id: 'boisson',
          name: 'Boisson',
          options: <ProductOption>[
            ProductOption(id: 'coca', name: 'Coca 33cl', priceDeltaCents: 500),
            ProductOption(id: 'eau', name: 'Eau', priceDeltaCents: 500),
          ],
        ),
      ],
    );
  }
}
