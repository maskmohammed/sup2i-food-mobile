import 'package:flutter/widgets.dart';

import '../features/orders/data/order_repository.dart';

/// Fournit l'[OrderRepository] partagé (stateful) à l'app.
class OrdersScope extends InheritedWidget {
  const OrdersScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final OrderRepository repository;

  static OrderRepository of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<OrdersScope>();
    assert(scope != null, 'OrdersScope introuvable dans l\'arbre de widgets.');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(OrdersScope oldWidget) =>
      repository != oldWidget.repository;
}
