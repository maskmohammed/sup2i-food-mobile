import 'package:flutter/widgets.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

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
      return PhosphorIconsRegular.hamburger;
    case 'pizza':
      return PhosphorIconsRegular.pizza;
    case 'pasticio':
      return PhosphorIconsRegular.bowlFood;
    case 'boisson':
      return PhosphorIconsRegular.coffee;
    case 'dessert':
      return PhosphorIconsRegular.iceCream;
    default:
      return PhosphorIconsRegular.forkKnife;
  }
}
