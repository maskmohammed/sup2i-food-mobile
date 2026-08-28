import 'package:flutter/material.dart';

import '../../../app/auth_guard.dart';
import '../../../app/cart_scope.dart';
import '../../../app/orders_scope.dart';
import '../../../core/error/api_exception.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/format/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalogue/presentation/widgets/product_image.dart';
import '../../catalogue/presentation/widgets/product_options_sheet.dart';
import '../../orders/presentation/order_tracking_page.dart';
import '../../orders/presentation/widgets/payment_method_sheet.dart';
import '../application/cart_controller.dart';
import '../data/slot_repository.dart';
import '../domain/cart_line.dart';
import 'slot_page.dart';

/// Écran Panier : lignes, créneau de retrait, sous-total **indicatif**,
/// bouton Commander (actif seulement après choix d'un créneau ; commande → M6).
class CartPage extends StatelessWidget {
  const CartPage({super.key, this.slotRepository});

  /// Passé à l'écran de créneaux (injectable pour les tests).
  final SlotRepository? slotRepository;

  Future<void> _checkout(
    BuildContext context,
    CartController cart,
    AppLocalizations loc,
  ) async {
    // Passage de commande = action protégée (mode invité).
    if (!AuthGuard.require(context, message: loc.loginWallCartMessage)) return;
    final method = await showPaymentMethodSheet(context);
    if (method == null || !context.mounted) return;
    final repo = OrdersScope.of(context);
    try {
      final order = await repo.createOrder(
        lines: cart.lines,
        slotLabel: cart.slot!.label,
        paymentMethod: method,
      );
      AppHaptics.success(); // confirmation supplémentaire (l'écran suivi suit)
      cart.clear();
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OrderTrackingPage(orderId: order.id),
        ),
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.errorMessage(e.code))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final CartController cart = CartScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.cartTitle)),
      body: cart.isEmpty
          ? AppStateView.empty(
              icon: Icons.shopping_cart_outlined,
              title: loc.cartEmptyTitle,
              message: loc.cartEmptyHint,
              actionLabel: loc.discoverMenu,
              onAction: () => Navigator.of(context).pop(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.lines.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _CartLineTile(line: cart.lines[index], cart: cart),
                  ),
                ),
                _SlotRow(
                  label: cart.slot?.label ?? loc.noSlotSelected,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SlotPage(repository: slotRepository),
                    ),
                  ),
                ),
                _Totals(subtotalCents: cart.subtotalCents),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: cart.slot == null
                          ? null
                          : () => _checkout(context, cart, loc),
                      child: Text(loc.checkout),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line, required this.cart});

  final CartLine line;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: context.surfaces.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.surfaces.border),
      ),
      child: InkWell(
        // Taper la ligne rouvre la personnalisation (suppléments, frites…) en
        // ÉDITION : la ligne est remplacée, pas dupliquée.
        onTap: () => showProductOptionsSheet(
          context,
          productId: line.productId,
          productName: line.name,
          editLine: line,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Miniature produit (même mécanisme/placeholder que le catalogue).
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: ExcludeSemantics(
                    child: ProductImage(query: line.name, iconSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Regroupe nom + options + prix en une seule annonce lecteur.
              Expanded(
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(line.name, style: text.bodyMedium),
                      if (line.optionsLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          line.optionsLabel!,
                          style: text.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        Money.format(line.unitPriceCents),
                        style: text.labelLarge?.copyWith(
                          color: context.surfaces.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => cart.decrement(line.id),
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.navy900,
                tooltip: loc.decreaseQuantity,
              ),
              Text(
                '${line.quantity}',
                semanticsLabel: '${loc.quantityLabel} : ${line.quantity}',
              ),
              IconButton(
                onPressed: () => cart.increment(line.id),
                icon: const Icon(Icons.add_circle),
                color: AppColors.pink600,
                tooltip: loc.increaseQuantity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.schedule, color: AppColors.pink600),
      title: Text(loc.pickupSlotLabel, style: text.bodySmall),
      subtitle: Text(label, style: text.bodyMedium),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.subtotalCents});

  final int subtotalCents;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final formatted = Money.format(subtotalCents);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.subtotalLabel,
                style: text.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              Text(formatted, style: text.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.totalLabel,
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                formatted,
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            loc.totalIndicativeNote,
            style: text.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
