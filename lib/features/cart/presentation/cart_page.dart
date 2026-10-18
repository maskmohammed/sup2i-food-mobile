import 'package:flutter/material.dart';

import '../../../app/cart_scope.dart';
import '../../../app/orders_scope.dart';
import '../../../core/error/api_exception.dart';
import '../../../core/format/money.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalogue/presentation/widgets/product_image.dart';
import '../../catalogue/presentation/widgets/product_options_sheet.dart';
import '../../orders/presentation/order_confirmation_page.dart';
import '../../orders/presentation/widgets/payment_method_sheet.dart';
import '../application/cart_controller.dart';
import '../data/slot_repository.dart';
import '../domain/cart_line.dart';
import 'slot_page.dart';

/// Final student cart.
///
/// Authentication is mandatory before the authenticated app shell, so this
/// screen no longer duplicates guest guards. Server/repository validation
/// remains authoritative at order creation.
class CartPage extends StatefulWidget {
  const CartPage({super.key, this.slotRepository});

  final SlotRepository? slotRepository;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _submitting = false;

  Future<void> _checkout(
    BuildContext context,
    CartController cart,
    AppLocalizations loc,
  ) async {
    if (_submitting || cart.slot == null) return;

    final method = await showPaymentMethodSheet(context);
    if (method == null || !context.mounted) return;

    setState(() => _submitting = true);

    final repo = OrdersScope.of(context);

    try {
      final order = await repo.createOrder(
        lines: cart.lines,
        slotLabel: cart.slot!.label,
        paymentMethod: method,
      );

      AppHaptics.success();
      cart.clear();

      if (!context.mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OrderConfirmationPage(order: order),
        ),
      );
    } on ApiException catch (error) {
      if (!context.mounted) return;

      setState(() => _submitting = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.errorMessage(error.code))));
    } on Object {
      if (!context.mounted) return;

      setState(() => _submitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.errorMessage('INTERNAL_ERROR'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cart = CartScope.of(context);

    return Scaffold(
      key: const Key('cart_screen'),
      backgroundColor: context.surfaces.background,
      appBar: AppBar(
        title: Text(loc.cartTitle),
        actions: <Widget>[
          if (!cart.isEmpty)
            IconButton(
              key: const Key('cart_clear'),
              onPressed: _submitting ? null : cart.clear,
              tooltip: 'Vider le panier',
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: cart.isEmpty
          ? AppStateView.empty(
              icon: Icons.shopping_bag_outlined,
              title: loc.cartEmptyTitle,
              message: loc.cartEmptyHint,
              actionLabel: loc.discoverMenu,
              onAction: () => Navigator.of(context).pop(),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    key: const Key('cart_lines'),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                    itemCount: cart.lines.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _CartLineCard(
                      line: cart.lines[index],
                      cart: cart,
                      enabled: !_submitting,
                    ),
                  ),
                ),
                _CheckoutPanel(
                  cart: cart,
                  submitting: _submitting,
                  onChooseSlot: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          SlotPage(repository: widget.slotRepository),
                    ),
                  ),
                  onCheckout: () => _checkout(context, cart, loc),
                ),
              ],
            ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({
    required this.line,
    required this.cart,
    required this.enabled,
  });

  final CartLine line;
  final CartController cart;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Material(
      color: context.surfaces.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.surfaces.border),
      ),
      child: InkWell(
        onTap: enabled
            ? () => showProductOptionsSheet(
                context,
                productId: line.productId,
                productName: line.name,
                editLine: line,
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: ExcludeSemantics(
                    child: ProductImage(query: line.name, iconSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      line.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.navy900,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (line.optionsLabel != null) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        line.optionsLabel!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      Money.format(line.unitPriceCents),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.pink600,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CompactStepper(
                line: line,
                cart: cart,
                enabled: enabled,
                loc: loc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactStepper extends StatelessWidget {
  const _CompactStepper({
    required this.line,
    required this.cart,
    required this.enabled,
    required this.loc,
  });

  final CartLine line;
  final CartController cart;
  final bool enabled;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaces.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: enabled ? () => cart.increment(line.id) : null,
            tooltip: loc.increaseQuantity,
            icon: const Icon(Icons.add_rounded),
            color: AppColors.pink600,
          ),
          Text(
            '${line.quantity}',
            semanticsLabel: '${loc.quantityLabel} : ${line.quantity}',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: enabled ? () => cart.decrement(line.id) : null,
            tooltip: loc.decreaseQuantity,
            icon: const Icon(Icons.remove_rounded),
            color: AppColors.navy900,
          ),
        ],
      ),
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  const _CheckoutPanel({
    required this.cart,
    required this.submitting,
    required this.onChooseSlot,
    required this.onCheckout,
  });

  final CartController cart;
  final bool submitting;
  final VoidCallback onChooseSlot;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final formatted = Money.format(cart.subtotalCents);

    return Material(
      color: context.surfaces.surface,
      elevation: 12,
      shadowColor: const Color(0x24161B5C),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                key: const Key('cart_slot_selector'),
                onTap: submitting ? null : onChooseSlot,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cart.slot == null
                        ? AppColors.softPink
                        : AppColors.softBlue,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: AppColors.neutral0,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
                          color: AppColors.pink600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              loc.pickupSlotLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cart.slot?.label ?? loc.noSlotSelected,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: AppColors.navy900,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.navy900,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    loc.subtotalLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                  Text(
                    formatted,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    loc.totalLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  Text(
                    formatted,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.pink600,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  loc.totalIndicativeNote,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  key: const Key('cart_checkout'),
                  onPressed: cart.slot == null || submitting
                      ? null
                      : onCheckout,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: submitting
                        ? const SizedBox(
                            key: ValueKey('cart_submitting'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.neutral0,
                            ),
                          )
                        : Text(
                            loc.checkout,
                            key: const ValueKey('cart_checkout_label'),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
