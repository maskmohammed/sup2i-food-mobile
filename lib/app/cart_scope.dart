import 'package:flutter/widgets.dart';

import '../features/cart/application/cart_controller.dart';

/// Fournit le [CartController] à toute l'app (badge panier, écran Panier,
/// ajout depuis catalogue/détail).
class CartScope extends InheritedNotifier<CartController> {
  const CartScope({
    super.key,
    required CartController controller,
    required super.child,
  }) : super(notifier: controller);

  static CartController of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<CartScope>()
        : context.getInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope introuvable dans l\'arbre de widgets.');
    return scope!.notifier!;
  }
}
