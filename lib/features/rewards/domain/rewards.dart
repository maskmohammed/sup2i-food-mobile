/// Promotion / offre (source serveur — jamais de règle prix locale comme autorité).
class Promotion {
  const Promotion({
    required this.id,
    required this.title,
    required this.description,
    this.badgeLabel,
  });

  final String id;
  final String title;
  final String description;
  final String? badgeLabel;
}

/// Solde de fidélité de l'étudiant (calculé serveur).
class LoyaltyBalance {
  const LoyaltyBalance({required this.points, required this.tierLabel});

  final int points;
  final String tierLabel;
}

/// Entrée d'historique de fidélité (gain/dépense).
class LoyaltyEntry {
  const LoyaltyEntry({
    required this.label,
    required this.points,
    required this.dateLabel,
  });

  final String label;
  final int points; // positif = gagné, négatif = utilisé
  final String dateLabel;
}
