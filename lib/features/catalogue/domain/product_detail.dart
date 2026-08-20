import 'product.dart';

/// Une option sélectionnable (supplément, boisson…). Le delta de prix est
/// indicatif et fourni par le serveur ; le total réel reste autorité serveur.
class ProductOption {
  const ProductOption({
    required this.id,
    required this.name,
    required this.priceDeltaCents,
  });

  final String id;
  final String name;
  final int priceDeltaCents;
}

/// Groupe d'options (« Suppléments », « Accompagnement », « Boisson »).
class ProductOptionGroup {
  const ProductOptionGroup({
    required this.id,
    required this.name,
    required this.options,
  });

  final String id;
  final String name;
  final List<ProductOption> options;
}

/// Fiche détaillée d'un produit : produit + options + note + durée de prépa.
///
/// ⚠️ Forme provisoire alignée sur les entités SQL (aucun OpenAPI) —
/// cf. `docs/api/MISSING_CONTRACTS.md`.
class ProductDetail {
  const ProductDetail({
    required this.product,
    this.optionGroups = const <ProductOptionGroup>[],
    this.note,
    this.prepMinutes,
  });

  final Product product;
  final List<ProductOptionGroup> optionGroups;
  final String? note;
  final int? prepMinutes;
}
