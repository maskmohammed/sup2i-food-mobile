import '../domain/category.dart';
import '../domain/product.dart';

/// Contrat d'accès au catalogue (produits, catégories).
///
/// Implémentation actuelle : [MockCatalogueRepository] (aucun backend/OpenAPI).
/// Prix, disponibilité et catégories restent **autorité serveur**.
abstract interface class CatalogueRepository {
  Future<List<Category>> categories();

  /// Produits, filtrés côté source si [categoryId] est fourni (`null` = tous).
  Future<List<Product>> products({String? categoryId});
}
