import '../domain/canteen.dart';

/// Contrat d'accès à la cantine (menu, abonnement, Food Pass).
///
/// Implémentation actuelle : [MockCanteenRepository] (aucun backend/OpenAPI).
/// Abonnement, quota et statut Food Pass restent **autorité serveur**.
abstract interface class CanteenRepository {
  Future<List<MealDay>> weeklyMenu();
  Future<Subscription> subscription();
  Future<FoodPass> foodPass();
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
      MealDay(label: 'Plat Lundi', description: 'Poulet rôti, riz, légumes'),
      MealDay(label: 'Plat Mardi', description: 'Tajine de bœuf'),
      MealDay(label: 'Plat Mercredi', description: 'Poisson, pommes de terre'),
      MealDay(label: 'Plat Jeudi', description: 'Couscous légumes'),
      MealDay(label: 'Plat Vendredi', description: 'Pâtes bolognaise'),
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
}
