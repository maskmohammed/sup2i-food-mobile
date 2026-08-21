/// Plat d'un jour du menu cantine.
class MealDay {
  const MealDay({required this.label, this.description});

  final String label;
  final String? description;
}

/// Abonnement cantine. **Activé par l'Administration** — le Mobile n'active
/// jamais. Quota calculé serveur (renouvellement hebdomadaire).
class Subscription {
  const Subscription({
    required this.planName,
    required this.active,
    required this.validUntil,
    required this.quotaRemaining,
    required this.quotaTotal,
    this.historyWeekLabel,
    this.historyUsed,
    this.historyTotal,
  });

  final String planName;
  final bool active;
  final DateTime validUntil;
  final int quotaRemaining;
  final int quotaTotal;
  final String? historyWeekLabel;
  final int? historyUsed;
  final int? historyTotal;
}

/// Statut du Food Pass (jamais signalé par la couleur seule).
enum FoodPassStatus { active, blocked, lost, expired, revoked }

/// Food Pass numérique. 1 seul `active` par étudiant. Photo modifiable
/// uniquement par l'Administration (jamais côté Mobile).
class FoodPass {
  const FoodPass({
    required this.studentName,
    required this.studentId,
    required this.status,
    required this.qrPayload,
  });

  final String studentName;
  final String studentId;
  final FoodPassStatus status;
  final String qrPayload;
}
