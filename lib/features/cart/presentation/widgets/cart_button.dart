import 'package:flutter/material.dart';

import '../../../../app/cart_scope.dart';
import '../../../../core/theme/app_motion.dart';
import '../cart_page.dart';

/// Icône panier avec badge de quantité, ouvre l'écran Panier.
///
/// Le badge fait un léger scale (charte : 160–200 ms) à chaque ajout d'article
/// pour confirmer l'action. Respecte `prefers-reduced-motion`.
class CartButton extends StatefulWidget {
  const CartButton({super.key});

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.cartAdd,
    lowerBound: 1,
    upperBound: 1.35,
  );

  int _lastCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCountChanged(int count) {
    if (count > _lastCount && !AppMotion.reduceMotion(context)) {
      _controller.forward(from: 1).then((_) {
        if (mounted) _controller.reverse();
      });
    }
    _lastCount = count;
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    // Déclenche le rebond après la frame courante (évite setState en build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onCountChanged(cart.itemCount);
    });

    return IconButton(
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const CartPage())),
      icon: ScaleTransition(
        scale: _controller,
        child: Badge(
          isLabelVisible: cart.itemCount > 0,
          label: Text('${cart.itemCount}'),
          child: const Icon(Icons.shopping_bag_outlined),
        ),
      ),
    );
  }
}
