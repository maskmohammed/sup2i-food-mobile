import 'package:flutter/material.dart';

import '../../../../app/cart_scope.dart';
import '../../../../core/widgets/badged_icon_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../cart_page.dart';

/// Icône panier avec badge de quantité (composant partagé [BadgedIconButton]).
/// Ouvre l'écran Panier. Le badge n'apparaît que si le panier n'est pas vide.
class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final count = CartScope.of(context).itemCount;

    return BadgedIconButton(
      icon: Icons.shopping_bag_outlined,
      count: count,
      tooltip: loc.cartTooltip,
      semanticLabel: loc.cartItemsA11y(count),
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const CartPage())),
    );
  }
}
