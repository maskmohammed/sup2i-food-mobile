/// Catalogue des codes d'erreur API (gelé — cf. CLAUDE.md / SESSION_SUMMARY).
///
/// La gestion d'erreurs se fait **toujours sur ce `code`**, jamais sur le
/// `message` renvoyé par le serveur.
abstract final class ApiCodes {
  // Auth / compte
  static const String unauthorized = 'UNAUTHORIZED';
  static const String accountBlocked = 'ACCOUNT_BLOCKED';
  static const String accountSuspended = 'ACCOUNT_SUSPENDED';

  // Catalogue / commande
  static const String productUnavailable = 'PRODUCT_UNAVAILABLE';
  static const String invalidProductOption = 'INVALID_PRODUCT_OPTION';
  static const String outOfStock = 'OUT_OF_STOCK';
  static const String slotClosed = 'SLOT_CLOSED';
  static const String slotFull = 'SLOT_FULL';
  static const String maxActiveOrdersReached = 'MAX_ACTIVE_ORDERS_REACHED';
  static const String invalidOrderStatus = 'INVALID_ORDER_STATUS';
  static const String orderExpired = 'ORDER_EXPIRED';
  static const String paymentFailed = 'PAYMENT_FAILED';

  // QR / Food Pass
  static const String invalidQr = 'INVALID_QR';
  static const String qrExpired = 'QR_EXPIRED';
  static const String qrRevoked = 'QR_REVOKED';
  static const String foodPassBlocked = 'FOOD_PASS_BLOCKED';
  static const String foodPassLost = 'FOOD_PASS_LOST';
  static const String foodPassRevoked = 'FOOD_PASS_REVOKED';
  static const String foodPassExpired = 'FOOD_PASS_EXPIRED';

  // Cantine / abonnement
  static const String subscriptionInactive = 'SUBSCRIPTION_INACTIVE';
  static const String entitlementExpired = 'ENTITLEMENT_EXPIRED';
  static const String mealNotAllowed = 'MEAL_NOT_ALLOWED';
  static const String quotaExhausted = 'QUOTA_EXHAUSTED';
  static const String dailyLimitReached = 'DAILY_LIMIT_REACHED';
  static const String mealAlreadyUsed = 'MEAL_ALREADY_USED';
  static const String canteenReservationClosed = 'CANTEEN_RESERVATION_CLOSED';
  static const String canteenAlreadyReserved = 'CANTEEN_ALREADY_RESERVED';

  // Promo / fidélité
  static const String promotionConflict = 'PROMOTION_CONFLICT';
  static const String loyaltyBalanceInsufficient =
      'LOYALTY_BALANCE_INSUFFICIENT';

  // Transverses
  static const String rateLimited = 'RATE_LIMITED';
  static const String internalError = 'INTERNAL_ERROR';

  /// Pseudo-code côté client (échec réseau/connexion) — hors catalogue serveur.
  static const String networkError = 'NETWORK_ERROR';
}
