import '../domain/app_notification.dart';

/// Contrat d'accès aux notifications et préférences.
/// Le contenu/état vient du serveur (push M9) ; les préférences y sont
/// persistées (par catégorie).
abstract interface class NotificationsRepository {
  Future<List<AppNotification>> list();
  Future<Map<NotificationCategory, bool>> preferences();
  Future<void> setPreference(NotificationCategory category, bool enabled);
}

/// Mock **stateful** (préférences modifiables) en attendant le backend.
class MockNotificationsRepository implements NotificationsRepository {
  MockNotificationsRepository({
    this.latency = const Duration(milliseconds: 300),
  });

  final Duration latency;

  final Map<NotificationCategory, bool> _prefs = <NotificationCategory, bool>{
    NotificationCategory.transactional: true,
    NotificationCategory.canteen: true,
    NotificationCategory.promotions: false,
    NotificationCategory.marketing: false,
  };

  @override
  Future<List<AppNotification>> list() async {
    await Future<void>.delayed(latency);
    return const <AppNotification>[
      AppNotification(
        id: 'n1',
        type: NotificationType.orderReady,
        title: 'Votre commande est prête',
        body: 'Commande #A1949 à retirer',
        timeLabel: 'Il y a 5 min',
        read: false,
      ),
      AppNotification(
        id: 'n2',
        type: NotificationType.paymentConfirmed,
        title: 'Paiement confirmé',
        body: 'Commande #A1949 payée',
        timeLabel: 'Il y a 8 min',
        read: false,
      ),
      AppNotification(
        id: 'n3',
        type: NotificationType.quotaLow,
        title: 'Quota faible',
        body: 'Il vous reste 2 repas cette semaine',
        timeLabel: 'Hier',
        read: true,
      ),
      AppNotification(
        id: 'n4',
        type: NotificationType.reservationConfirmed,
        title: 'Réservation confirmée',
        body: 'Menu de mardi réservé',
        timeLabel: 'Hier',
        read: true,
      ),
    ];
  }

  @override
  Future<Map<NotificationCategory, bool>> preferences() async {
    await Future<void>.delayed(latency);
    return Map<NotificationCategory, bool>.unmodifiable(_prefs);
  }

  @override
  Future<void> setPreference(
    NotificationCategory category,
    bool enabled,
  ) async {
    await Future<void>.delayed(latency);
    _prefs[category] = enabled;
  }
}
