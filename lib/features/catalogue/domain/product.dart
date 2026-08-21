/// Produit du catalogue.
///
/// Prix en **centimes** (cf. [Money]). `available` reflète la disponibilité
/// serveur (le Mobile ne recalcule pas le stock). Les allergènes sont fournis
/// en **texte** (affichés en chips, jamais uniquement via la photo).
///
/// ⚠️ Forme provisoire alignée sur les entités SQL (aucun OpenAPI fourni) —
/// cf. `docs/api/MISSING_CONTRACTS.md`.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.priceCents,
    required this.available,
    this.description,
    this.allergens = const <String>[],
  });

  final String id;
  final String name;
  final String categoryId;
  final int priceCents;
  final bool available;
  final String? description;
  final List<String> allergens;
}
