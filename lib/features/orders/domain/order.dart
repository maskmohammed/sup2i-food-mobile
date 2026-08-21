import '../../cart/domain/cart_line.dart';

/// Statuts de commande (state machine gelée).
/// Ligne principale : DRAFT → CREATED → AWAITING_PAYMENT → PAID → QUEUED →
/// PREPARING → READY → COLLECTED → COMPLETED. Alternatifs en fin d'enum.
enum OrderStatus {
  draft,
  created,
  awaitingPayment,
  paid,
  queued,
  preparing,
  ready,
  collected,
  completed,
  cancelled,
  expired,
  refunded,
  noShow,
}

extension OrderStatusX on OrderStatus {
  /// Annulable uniquement **avant** PREPARING (règle gelée).
  bool get isCancelable => const <OrderStatus>{
    OrderStatus.created,
    OrderStatus.awaitingPayment,
    OrderStatus.paid,
    OrderStatus.queued,
  }.contains(this);

  bool get isTerminal => const <OrderStatus>{
    OrderStatus.completed,
    OrderStatus.collected,
    OrderStatus.cancelled,
    OrderStatus.expired,
    OrderStatus.refunded,
    OrderStatus.noShow,
  }.contains(this);
}

/// Moyens de paiement MVP (gelé). Le Mobile ne confirme jamais un paiement.
enum PaymentMethod { cash, cardTpe }

/// Commande. Le [totalCents] est renvoyé par le serveur (autorité) — le Mobile
/// ne le recalcule pas.
class Order {
  const Order({
    required this.id,
    required this.number,
    required this.status,
    required this.lines,
    required this.totalCents,
    required this.createdAt,
    this.slotLabel,
    this.paymentMethod,
  });

  final String id;
  final String number;
  final OrderStatus status;
  final List<CartLine> lines;
  final int totalCents;
  final DateTime createdAt;
  final String? slotLabel;
  final PaymentMethod? paymentMethod;

  Order copyWith({OrderStatus? status}) => Order(
    id: id,
    number: number,
    status: status ?? this.status,
    lines: lines,
    totalCents: totalCents,
    createdAt: createdAt,
    slotLabel: slotLabel,
    paymentMethod: paymentMethod,
  );
}
