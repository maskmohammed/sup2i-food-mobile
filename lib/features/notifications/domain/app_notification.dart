/// Type de notification (détermine la pastille de couleur).
enum NotificationType {
  orderReady,
  paymentConfirmed,
  quotaLow,
  reservationConfirmed,
  generic,
}

/// Notification reçue (serveur / push M9). Le type/état ne sont pas décidés
/// localement.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.read,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String timeLabel;
  final bool read;
}

/// Catégories de préférences de notifications.
enum NotificationCategory { transactional, canteen, promotions, marketing }
