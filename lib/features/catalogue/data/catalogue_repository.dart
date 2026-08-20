import '../domain/category.dart';
import '../domain/product.dart';
import '../domain/product_detail.dart';

/// Contrat d'accès au catalogue (produits, catégories).
///
/// Implémentation actuelle : [MockCatalogueRepository] (aucun backend/OpenAPI).
/// Prix, disponibilité et catégories restent **autorité serveur**.
abstract interface class CatalogueRepository {
  Future<List<Category>> categories();

  /// Produits, filtrés côté source si [categoryId] est fourni (`null` = tous).
  Future<List<Product>> products({String? categoryId});

  /// Fiche détaillée. Lève [ApiException] `PRODUCT_UNAVAILABLE` si introuvable.
  Future<ProductDetail> productDetail(String productId);
}
