import '../domain/rewards.dart';

/// Contrat d'accès aux promotions et à la fidélité (autorité serveur).
abstract interface class RewardsRepository {
  Future<List<Promotion>> promotions();
  Future<LoyaltyBalance> loyalty();
  Future<List<LoyaltyEntry>> loyaltyHistory();
}

/// Données mock (M10, « si API prête »), lecture seule.
class MockRewardsRepository implements RewardsRepository {
  const MockRewardsRepository({
    this.latency = const Duration(milliseconds: 300),
  });

  final Duration latency;

  @override
  Future<List<Promotion>> promotions() async {
    await Future<void>.delayed(latency);
    return const <Promotion>[
      Promotion(
        id: 'promo1',
        title: 'Menu étudiant -20%',
        description: 'Sur tout le menu Snack, du lundi au vendredi.',
        badgeLabel: '-20%',
      ),
      Promotion(
        id: 'promo2',
        title: 'Boisson offerte',
        description: 'Une boisson offerte dès 50,00 DH d\'achat.',
        badgeLabel: 'Offert',
      ),
    ];
  }

  @override
  Future<LoyaltyBalance> loyalty() async {
    await Future<void>.delayed(latency);
    return const LoyaltyBalance(points: 240, tierLabel: 'Argent');
  }

  @override
  Future<List<LoyaltyEntry>> loyaltyHistory() async {
    await Future<void>.delayed(latency);
    return const <LoyaltyEntry>[
      LoyaltyEntry(label: 'Commande #A1949', points: 40, dateLabel: 'Hier'),
      LoyaltyEntry(
        label: 'Boisson offerte',
        points: -100,
        dateLabel: '12 août',
      ),
      LoyaltyEntry(label: 'Commande #B1990', points: 30, dateLabel: '11 août'),
    ];
  }
}
