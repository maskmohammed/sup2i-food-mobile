/// Ligne de panier. Le prix unitaire est **indicatif** (base + deltas d'options
/// affichés côté serveur) ; le total définitif reste autorité serveur à la
/// commande.
class CartLine {
  const CartLine({
    required this.id,
    required this.productId,
    required this.name,
    required this.unitPriceCents,
    required this.quantity,
    this.optionsLabel,
  });

  /// Clé stable = produit + options (permet de fusionner les lignes identiques).
  final String id;
  final String productId;
  final String name;
  final int unitPriceCents;
  final int quantity;
  final String? optionsLabel;

  int get lineTotalCents => unitPriceCents * quantity;

  CartLine copyWith({int? quantity}) => CartLine(
    id: id,
    productId: productId,
    name: name,
    unitPriceCents: unitPriceCents,
    quantity: quantity ?? this.quantity,
    optionsLabel: optionsLabel,
  );
}
