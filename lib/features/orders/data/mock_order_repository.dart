import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../../cart/domain/cart_line.dart';
import '../domain/order.dart';
import 'order_repository.dart';

/// Repository mock **stateful** (tient lieu de serveur en attendant le backend).
///
/// Conserve les commandes en mémoire. Ne simule pas la confirmation de paiement
/// ni la progression serveur (PAID → PREPARING → … = M7, piloté serveur).
class MockOrderRepository implements OrderRepository {
  MockOrderRepository({this.latency = const Duration(milliseconds: 300)});

  final Duration latency;

  static const int _maxActiveOrders = 3;
  int _sequence = 1949;

  // Simulation de progression serveur (le Mobile ne décide de rien).
  static const List<OrderStatus> _progression = <OrderStatus>[
    OrderStatus.awaitingPayment,
    OrderStatus.paid,
    OrderStatus.queued,
    OrderStatus.preparing,
    OrderStatus.ready,
  ];
  final Set<String> _liveOrders = <String>{};
  final Map<String, int> _polls = <String, int>{};

  // Historique de démo (statuts variés).
  final List<Order> _orders = <Order>[
    Order(
      id: 'o_a1949',
      number: 'A1949',
      status: OrderStatus.collected,
      lines: const <CartLine>[
        CartLine(
          id: 'p1|',
          productId: 'p1',
          name: 'Tacos Poulet XL',
          unitPriceCents: 4000,
          quantity: 1,
        ),
      ],
      totalCents: 4500,
      createdAt: DateTime(2026, 8, 20, 12, 45),
      slotLabel: '12h30 - 12h45',
      paymentMethod: PaymentMethod.cash,
    ),
    Order(
      id: 'o_b1990',
      number: 'B1990',
      status: OrderStatus.cancelled,
      lines: const <CartLine>[
        CartLine(
          id: 'p3|',
          productId: 'p3',
          name: 'Pasticio bœuf',
          unitPriceCents: 4000,
          quantity: 1,
        ),
      ],
      totalCents: 4000,
      createdAt: DateTime(2026, 8, 19, 13, 20),
      slotLabel: '13h00 - 13h15',
      paymentMethod: PaymentMethod.cardTpe,
    ),
  ];

  @override
  Future<Order> createOrder({
    required List<CartLine> lines,
    required String slotLabel,
    required PaymentMethod paymentMethod,
  }) async {
    await Future<void>.delayed(latency);
    final activeCount = _orders.where((o) => !o.status.isTerminal).length;
    if (activeCount >= _maxActiveOrders) {
      throw const ApiException(ApiCodes.maxActiveOrdersReached);
    }
    final total = lines.fold(0, (sum, l) => sum + l.lineTotalCents);
    final order = Order(
      id: 'o_$_sequence',
      number: 'A$_sequence',
      status: OrderStatus.awaitingPayment,
      lines: List<CartLine>.unmodifiable(lines),
      totalCents: total,
      createdAt: DateTime.now(),
      slotLabel: slotLabel,
      paymentMethod: paymentMethod,
    );
    _sequence++;
    _orders.insert(0, order);
    _liveOrders.add(order.id);
    return order;
  }

  @override
  Future<Order> getOrder(String orderId) async {
    await Future<void>.delayed(latency);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index < 0) throw const ApiException(ApiCodes.internalError);
    var order = _orders[index];

    // Avance d'un cran à chaque rafraîchissement (sauf le tout premier).
    if (_liveOrders.contains(orderId) && !order.status.isTerminal) {
      final polls = _polls[orderId] ?? 0;
      if (polls > 0) {
        final current = _progression.indexOf(order.status);
        if (current >= 0 && current < _progression.length - 1) {
          final next = _progression[current + 1];
          order = next == OrderStatus.queued
              ? order.copyWith(status: next, queuePosition: 3, etaMinutes: 8)
              : order.copyWith(status: next);
          _orders[index] = order;
        }
      }
      _polls[orderId] = polls + 1;
    }
    return order;
  }

  @override
  Future<Order> cancelOrder(String orderId) async {
    await Future<void>.delayed(latency);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index < 0) throw const ApiException(ApiCodes.internalError);
    final order = _orders[index];
    if (!order.status.isCancelable) {
      throw const ApiException(ApiCodes.invalidOrderStatus);
    }
    final updated = order.copyWith(status: OrderStatus.cancelled);
    _orders[index] = updated;
    return updated;
  }

  @override
  Future<List<Order>> listOrders() async {
    await Future<void>.delayed(latency);
    return List<Order>.unmodifiable(_orders);
  }
}
