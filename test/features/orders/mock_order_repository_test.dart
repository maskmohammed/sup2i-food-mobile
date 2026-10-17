import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/core/error/api_codes.dart';
import 'package:sup2i_food_mobile/core/error/api_exception.dart';
import 'package:sup2i_food_mobile/features/cart/domain/cart_line.dart';
import 'package:sup2i_food_mobile/features/orders/data/mock_order_repository.dart';
import 'package:sup2i_food_mobile/features/orders/domain/order.dart';

const _lines = <CartLine>[
  CartLine(
    id: 'p1|',
    productId: 'p1',
    name: 'Tacos',
    unitPriceCents: 4000,
    quantity: 2,
  ),
];

MockOrderRepository repo() => MockOrderRepository(latency: Duration.zero);

void main() {
  test(
    'createOrder : AWAITING_PAYMENT, total serveur, ajouté à la liste',
    () async {
      final r = repo();
      final order = await r.createOrder(
        lines: _lines,
        slotLabel: '12h00',
        paymentMethod: PaymentMethod.cash,
      );
      expect(order.status, OrderStatus.awaitingPayment);
      expect(order.totalCents, 8000);
      final list = await r.listOrders();
      expect(list.first.id, order.id);
    },
  );

  test('cancelOrder : annulable → CANCELLED', () async {
    final r = repo();
    final order = await r.createOrder(
      lines: _lines,
      slotLabel: '12h00',
      paymentMethod: PaymentMethod.cash,
    );
    final cancelled = await r.cancelOrder(order.id);
    expect(cancelled.status, OrderStatus.cancelled);
  });

  test('cancelOrder : commande retirée → INVALID_ORDER_STATUS', () async {
    final r = repo();
    // o_a1949 est COLLECTED dans le mock.
    expect(
      () => r.cancelOrder('o_a1949'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiCodes.invalidOrderStatus,
        ),
      ),
    );
  });

  test('progression : getOrder avance après le 1er appel', () async {
    final r = repo();
    final o = await r.createOrder(
      lines: _lines,
      slotLabel: '12h',
      paymentMethod: PaymentMethod.cash,
    );
    expect(o.status, OrderStatus.awaitingPayment);
    expect((await r.getOrder(o.id)).status, OrderStatus.awaitingPayment);
    expect((await r.getOrder(o.id)).status, OrderStatus.paid);
    final q = await r.getOrder(o.id);
    expect(q.status, OrderStatus.queued);
    expect(q.queuePosition, 3);
    expect((await r.getOrder(o.id)).status, OrderStatus.preparing);
    expect((await r.getOrder(o.id)).status, OrderStatus.ready);
    expect((await r.getOrder(o.id)).status, OrderStatus.ready);
  });

  test('reset : revient au jeu de données initial', () async {
    final r = repo();
    final seeded = (await r.listOrders()).length;
    await r.createOrder(
      lines: _lines,
      slotLabel: '12h00',
      paymentMethod: PaymentMethod.cash,
    );
    expect((await r.listOrders()).length, seeded + 1);

    r.reset();
    expect((await r.listOrders()).length, seeded);
  });

  test(
    'createOrder : au-delà de la limite → MAX_ACTIVE_ORDERS_REACHED',
    () async {
      final r = repo();
      for (var i = 0; i < 3; i++) {
        await r.createOrder(
          lines: _lines,
          slotLabel: '12h00',
          paymentMethod: PaymentMethod.cash,
        );
      }
      expect(
        () => r.createOrder(
          lines: _lines,
          slotLabel: '12h00',
          paymentMethod: PaymentMethod.cash,
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiCodes.maxActiveOrdersReached,
          ),
        ),
      );
    },
  );
}
