import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Icône Phosphor associée à une catégorie (affichage seul).
///
/// Mapping purement décoratif avec repli : les catégories restent autorité
/// serveur, ce mapping ne pilote aucune règle métier. Une catégorie inconnue
/// retombe sur une icône générique. Conformément à la charte (section 22), la
/// couleur de l'icône dépend de l'état UI (actif/inactif), jamais de la
/// catégorie — voir [CategorySelector].
IconData categoryIcon(String? categoryId) {
  switch (categoryId) {
    case 'tacos':
      return PhosphorIcons.hamburger();
    case 'pizza':
      return PhosphorIcons.pizza();
    case 'pasticio':
      return PhosphorIcons.bowlFood();
    case 'boisson':
      return PhosphorIcons.coffee();
    case 'dessert':
      return PhosphorIcons.iceCream();
    default:
      return PhosphorIcons.forkKnife();
  }
}
