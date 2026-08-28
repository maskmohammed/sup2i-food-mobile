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
    // — Tacos —
    Product(
      id: 'p1',
      name: 'Tacos Poulet XL',
      categoryId: 'tacos',
      priceCents: 4000,
      available: true,
      description: 'Galette, poulet mariné, frites, sauce fromagère.',
      allergens: <String>['Gluten', 'Lait'],
    ),
    Product(
      id: 'p6',
      name: 'Tacos Viande Hachée',
      categoryId: 'tacos',
      priceCents: 4000,
      available: true,
      description: 'Viande hachée, frites, sauce au choix.',
      allergens: <String>['Gluten'],
    ),
    Product(
      id: 'p7',
      name: 'Tacos Mixte',
      categoryId: 'tacos',
      priceCents: 4500,
      available: true,
      description: 'Poulet et viande hachée, double fromage.',
      allergens: <String>['Gluten', 'Lait'],
    ),
    Product(
      id: 'p8',
      name: 'Tacos Végétarien',
      categoryId: 'tacos',
      priceCents: 3500,
      available: true,
      description: 'Légumes grillés, falafels, sauce blanche.',
      allergens: <String>['Gluten', 'Sésame'],
    ),
    // — Pizza —
    Product(
      id: 'p2',
      name: 'Pizza margherita',
      categoryId: 'pizza',
      priceCents: 2500,
      available: true,
      description: 'Sauce tomate, mozzarella, basilic.',
      allergens: <String>['Gluten', 'Lait'],
    ),
    Product(
      id: 'p9',
      name: 'Pizza 4 Fromages',
      categoryId: 'pizza',
      priceCents: 3500,
      available: true,
      description: 'Mozzarella, emmental, chèvre, bleu.',
      allergens: <String>['Gluten', 'Lait'],
    ),
    Product(
      id: 'p10',
      name: 'Pizza Pepperoni',
      categoryId: 'pizza',
      priceCents: 3800,
      available: true,
      description: 'Sauce tomate, mozzarella, pepperoni.',
      allergens: <String>['Gluten', 'Lait'],
    ),
    Product(
      id: 'p11',
      name: 'Pizza Thon',
      categoryId: 'pizza',
      priceCents: 3500,
      available: true,
      description: 'Sauce tomate, thon, oignons, olives.',
      allergens: <String>['Gluten', 'Lait', 'Poisson'],
    ),
    // — Pasticio —
    Product(
      id: 'p3',
      name: 'Pasticio bœuf',
      categoryId: 'pasticio',
      priceCents: 4000,
      available: true,
      description: 'Pâtes gratinées au bœuf et béchamel.',
      allergens: <String>['Gluten', 'Œuf', 'Lait'],
    ),
    Product(
      id: 'p12',
      name: 'Pasticio poulet',
      categoryId: 'pasticio',
      priceCents: 3800,
      available: true,
      description: 'Pâtes gratinées au poulet et béchamel.',
      allergens: <String>['Gluten', 'Œuf', 'Lait'],
    ),
    // — Boisson — (une seule indisponible, pour exercer l'état)
    Product(
      id: 'p5',
      name: 'Jus d\'orange',
      categoryId: 'boisson',
      priceCents: 500,
      available: false,
      description: 'Pressé du jour.',
    ),
    Product(
      id: 'p13',
      name: 'Coca 33cl',
      categoryId: 'boisson',
      priceCents: 500,
      available: true,
    ),
    Product(
      id: 'p14',
      name: 'Eau minérale 50cl',
      categoryId: 'boisson',
      priceCents: 300,
      available: true,
    ),
    Product(
      id: 'p15',
      name: 'Thé à la menthe',
      categoryId: 'boisson',
      priceCents: 700,
      available: true,
      description: 'Thé vert, menthe fraîche.',
    ),
    // — Dessert —
    Product(
      id: 'p4',
      name: 'Cheesecake',
      categoryId: 'dessert',
      priceCents: 2500,
      available: true,
      description: 'Base spéculoos, coulis de fruits rouges.',
      allergens: <String>['Gluten', 'Lait', 'Œuf'],
    ),
    Product(
      id: 'p16',
      name: 'Tiramisu',
      categoryId: 'dessert',
      priceCents: 2800,
      available: true,
      description: 'Mascarpone, café, cacao.',
      allergens: <String>['Gluten', 'Lait', 'Œuf'],
    ),
    Product(
      id: 'p17',
      name: 'Fondant chocolat',
      categoryId: 'dessert',
      priceCents: 3000,
      available: true,
      description: 'Cœur coulant, chocolat noir.',
      allergens: <String>['Gluten', 'Lait', 'Œuf'],
    ),
    Product(
      id: 'p18',
      name: 'Salade de fruits',
      categoryId: 'dessert',
      priceCents: 2200,
      available: true,
      description: 'Fruits frais de saison.',
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

    final groups = _optionGroupsFor(product.categoryId);
    if (groups.isEmpty) return ProductDetail(product: product);
    return ProductDetail(
      product: product,
      prepMinutes: product.categoryId == 'tacos' ? 15 : 12,
      note: 'Personnalisez votre plat : accompagnement, suppléments, boisson.',
      optionGroups: groups,
    );
  }

  // Accompagnement « Frites » commun (démo « add frites »).
  static const ProductOptionGroup _accompagnement = ProductOptionGroup(
    id: 'accompagnement',
    name: 'Accompagnement',
    options: <ProductOption>[
      ProductOption(id: 'frites', name: 'Frites', priceDeltaCents: 500),
      ProductOption(id: 'salade', name: 'Salade', priceDeltaCents: 300),
    ],
  );

  static const ProductOptionGroup _boisson = ProductOptionGroup(
    id: 'boisson',
    name: 'Boisson',
    options: <ProductOption>[
      ProductOption(id: 'coca', name: 'Coca 33cl', priceDeltaCents: 500),
      ProductOption(id: 'eau', name: 'Eau', priceDeltaCents: 500),
    ],
  );

  /// Options par catégorie (démo). Frites/suppléments disponibles sur plusieurs
  /// familles ; desserts/boissons sans options.
  static List<ProductOptionGroup> _optionGroupsFor(String categoryId) {
    switch (categoryId) {
      case 'tacos':
        return const <ProductOptionGroup>[
          ProductOptionGroup(
            id: 'supplements',
            name: 'Suppléments',
            options: <ProductOption>[
              ProductOption(
                id: 'fromage',
                name: 'Fromage',
                priceDeltaCents: 300,
              ),
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
          _boisson,
        ];
      case 'pizza':
        return const <ProductOptionGroup>[
          ProductOptionGroup(
            id: 'supplements',
            name: 'Suppléments',
            options: <ProductOption>[
              ProductOption(
                id: 'extra_fromage',
                name: 'Extra fromage',
                priceDeltaCents: 300,
              ),
              ProductOption(
                id: 'champignons',
                name: 'Champignons',
                priceDeltaCents: 200,
              ),
              ProductOption(id: 'olives', name: 'Olives', priceDeltaCents: 0),
            ],
          ),
          _accompagnement,
          _boisson,
        ];
      case 'pasticio':
        return const <ProductOptionGroup>[_accompagnement, _boisson];
      default:
        return const <ProductOptionGroup>[];
    }
  }
}
