/// Catégorie de produits (Tacos, Pizza, …).
///
/// ⚠️ Forme provisoire alignée sur les entités SQL (aucun OpenAPI fourni) —
/// cf. `docs/api/MISSING_CONTRACTS.md`.
class Category {
  const Category({required this.id, required this.name});

  final String id;
  final String name;
}
