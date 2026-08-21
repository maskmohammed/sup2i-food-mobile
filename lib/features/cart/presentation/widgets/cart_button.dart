import 'package:flutter/material.dart';

import '../../../../app/cart_scope.dart';
import '../cart_page.dart';

/// Icône panier avec badge de quantité, ouvre l'écran Panier.
class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    return IconButton(
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const CartPage())),
      icon: Badge(
        isLabelVisible: cart.itemCount > 0,
        label: Text('${cart.itemCount}'),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}
