import '../domain/category.dart';
import '../domain/product.dart';
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
}
