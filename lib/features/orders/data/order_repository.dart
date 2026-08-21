import '../../cart/domain/cart_line.dart';
import '../domain/order.dart';

/// Contrat d'accès aux commandes.
///
/// Implémentation actuelle : [MockOrderRepository] (aucun backend/OpenAPI).
/// Le serveur reste autorité sur le total, les statuts et le paiement.
abstract interface class OrderRepository {
  /// Crée une commande depuis le panier. Statut initial `AWAITING_PAYMENT`
  /// (le paiement n'est jamais confirmé côté Mobile). Lève [ApiException]
  /// `MAX_ACTIVE_ORDERS_REACHED` / `SLOT_FULL` selon le cas.
  Future<Order> createOrder({
    required List<CartLine> lines,
    required String slotLabel,
    required PaymentMethod paymentMethod,
  });

  Future<Order> getOrder(String orderId);

  /// Annule une commande. Lève `INVALID_ORDER_STATUS` si déjà en préparation.
  Future<Order> cancelOrder(String orderId);

  /// Historique (plus récent d'abord).
  Future<List<Order>> listOrders();
}
