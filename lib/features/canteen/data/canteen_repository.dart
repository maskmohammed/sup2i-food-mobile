import '../domain/canteen.dart';

/// Contrat d'accès à la cantine (menu, abonnement, Food Pass).
///
/// Implémentation actuelle : [MockCanteenRepository] (aucun backend/OpenAPI).
/// Abonnement, quota et statut Food Pass restent **autorité serveur**.
abstract interface class CanteenRepository {
  Future<List<MealDay>> weeklyMenu();
  Future<Subscription> subscription();
  Future<FoodPass> foodPass();

  /// Réserve un repas. Peut lever `CANTEEN_RESERVATION_CLOSED` /
  /// `CANTEEN_ALREADY_RESERVED` / `MEAL_NOT_ALLOWED` selon le cas.
  Future<Reservation> reserve(String mealId);

  Future<void> cancelReservation(String reservationId);

  /// Déclare la perte du Food Pass : l'ancien QR est invalidé serveur
  /// (abonnement/quota/historique conservés).
  Future<void> declareLoss(LossReason reason);
}

/// Données cantine mock (M8), lecture seule.
class MockCanteenRepository implements CanteenRepository {
  const MockCanteenRepository({
    this.latency = const Duration(milliseconds: 300),
  });

  final Duration latency;

  @override
  Future<List<MealDay>> weeklyMenu() async {
    await Future<void>.delayed(latency);
    return const <MealDay>[
      MealDay(
        id: 'lundi',
        label: 'Plat Lundi',
        description: 'Salade verte · Poulet rôti, riz, légumes · Yaourt',
      ),
      MealDay(
        id: 'mardi',
        label: 'Plat Mardi',
        description: 'Soupe du jour · Tajine de bœuf aux pruneaux · Fruit',
      ),
      MealDay(
        id: 'mercredi',
        label: 'Plat Mercredi',
        description: 'Betteraves · Poisson pané, pommes de terre · Flan',
      ),
      MealDay(
        id: 'jeudi',
        label: 'Plat Jeudi',
        description: 'Carottes râpées · Couscous légumes · Orange',
      ),
      MealDay(
        id: 'vendredi',
        label: 'Plat Vendredi',
        description: 'Taboulé · Pâtes bolognaise · Compote de pommes',
      ),
    ];
  }

  @override
  Future<Subscription> subscription() async {
    await Future<void>.delayed(latency);
    return Subscription(
      planName: 'Plan Étudiant Standard',
      active: true,
      validUntil: DateTime(2026, 6, 30),
      quotaRemaining: 8,
      quotaTotal: 12,
      historyWeekLabel: 'Semaine du 11 août',
      historyUsed: 12,
      historyTotal: 12,
    );
  }

  @override
  Future<FoodPass> foodPass() async {
    await Future<void>.delayed(latency);
    return const FoodPass(
      studentName: 'Chnaf Yahya',
      studentId: '12345678',
      status: FoodPassStatus.active,
      qrPayload: 'FOODPASS-12345678',
    );
  }

  @override
  Future<Reservation> reserve(String mealId) async {
    await Future<void>.delayed(latency);
    final meals = await weeklyMenu();
    final meal = meals.firstWhere(
      (m) => m.id == mealId,
      orElse: () => meals.first,
    );
    return Reservation(
      id: 'res_$mealId',
      mealLabel: meal.description ?? meal.label,
      dateLabel: 'Mardi 19 août',
      cancelDeadlineLabel: '11h00',
    );
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    await Future<void>.delayed(latency);
  }

  @override
  Future<void> declareLoss(LossReason reason) async {
    await Future<void>.delayed(latency);
  }
}
