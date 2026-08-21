import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/core/error/api_codes.dart';
import 'package:sup2i_food_mobile/features/orders/application/order_tracking_controller.dart';
import 'package:sup2i_food_mobile/features/orders/application/orders_controller.dart';
import 'package:sup2i_food_mobile/features/orders/data/mock_order_repository.dart';
import 'package:sup2i_food_mobile/features/orders/domain/order.dart';

void main() {
  test('OrdersController.load : historique chargé', () async {
    final c = OrdersController(MockOrderRepository(latency: Duration.zero));
    await c.load();
    expect(c.orders.length, greaterThanOrEqualTo(2));
    expect(c.errorCode, isNull);
  });

  test('OrderTrackingController : load puis cancel annulable', () async {
    final repo = MockOrderRepository(latency: Duration.zero);
    final created = await repo.createOrder(
      lines: const [],
      slotLabel: '12h',
      paymentMethod: PaymentMethod.cash,
    );
    final c = OrderTrackingController(repo);
    await c.load(created.id);
    expect(c.order!.status, OrderStatus.awaitingPayment);

    final code = await c.cancel();
    expect(code, isNull);
    expect(c.order!.status, OrderStatus.cancelled);
  });

  test('OrderTrackingController : cancel refusé → code retourné', () async {
    final repo = MockOrderRepository(latency: Duration.zero);
    final c = OrderTrackingController(repo);
    await c.load('o_a1949'); // COLLECTED
    final code = await c.cancel();
    expect(code, ApiCodes.invalidOrderStatus);
  });
}
