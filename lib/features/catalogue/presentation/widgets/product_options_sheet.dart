import 'package:flutter/material.dart';

import '../../../../app/cart_scope.dart';
import '../../../../core/format/money.dart';
import '../../../../core/haptics/app_haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_surfaces.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/domain/cart_line.dart';
import '../../application/product_detail_controller.dart';
import '../../data/catalogue_repository.dart';
import '../../data/mock_catalogue_repository.dart';
import '../../domain/product_detail.dart';

/// Feuille de personnalisation ouverte depuis le bouton « + » (ajout) ou depuis
/// une ligne du panier ([editLine] non nul → **édition** : la ligne d'origine
/// est remplacée, pas dupliquée). Réutilise [ProductDetailController] (prix
/// indicatif ; total réel = autorité serveur).
Future<void> showProductOptionsSheet(
  BuildContext context, {
  required String productId,
  required String productName,
  CatalogueRepository? repository,
  CartLine? editLine,
}) async {
  final controller = ProductDetailController(
    repository ?? const MockCatalogueRepository(),
  )..load(productId);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _OptionsSheet(
      controller: controller,
      fallbackName: productName,
      editLine: editLine,
    ),
  );
  controller.dispose();
}

class _OptionsSheet extends StatefulWidget {
  const _OptionsSheet({
    required this.controller,
    required this.fallbackName,
    this.editLine,
  });

  final ProductDetailController controller;
  final String fallbackName;
  final CartLine? editLine;

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  bool _prefilled = false;

  ProductDetailController get controller => widget.controller;

  /// Préremplit quantité + options depuis la ligne éditée (une seule fois,
  /// dès que le détail est chargé).
  void _applyEditPrefill(ProductDetail detail) {
    if (_prefilled || widget.editLine == null) return;
    _prefilled = true;
    final line = widget.editLine!;
    final names = (line.optionsLabel ?? '')
        .split(', ')
        .where((s) => s.isNotEmpty)
        .toSet();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.setQuantity(line.quantity);
      for (final group in detail.optionGroups) {
        for (final option in group.options) {
          if (names.contains(option.name) &&
              !controller.isSelected(option.id)) {
            controller.toggleOption(option.id);
          }
        }
      }
    });
  }

  void _confirm(BuildContext context, ProductDetail detail) {
    final loc = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cart = CartScope.of(context, listen: false);
    // Édition : on retire la ligne d'origine pour la remplacer (pas de doublon).
    if (widget.editLine != null) cart.remove(widget.editLine!.id);
    cart.addItem(
      productId: detail.product.id,
      name: detail.product.name,
      unitPriceCents: controller.indicativeUnitPriceCents,
      quantity: controller.quantity,
      optionsLabel: controller.selectedOptionsLabel,
    );
    AppHaptics.light();
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(loc.addedToCart)));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final detail = controller.detail;
            if (detail == null) {
              return const SizedBox(
                height: 160,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.pink600),
                ),
              );
            }
            _applyEditPrefill(detail);
            final indicativeTotal =
                controller.indicativeUnitPriceCents * controller.quantity;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.product.name, style: text.titleLarge),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _QuantityRow(controller: controller, loc: loc),
                        for (final group in detail.optionGroups)
                          _OptionGroup(
                            group: group,
                            controller: controller,
                            loc: loc,
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.totalIndicativeNote,
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => _confirm(context, detail),
                    child: Text(
                      '${loc.addToCart} · ${Money.format(indicativeTotal)}',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({required this.controller, required this.loc});

  final ProductDetailController controller;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(loc.quantityLabel, style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        IconButton(
          onPressed: controller.decrement,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.navy900,
          tooltip: loc.decreaseQuantity,
        ),
        Text(
          '${controller.quantity}',
          semanticsLabel: '${loc.quantityLabel} : ${controller.quantity}',
        ),
        IconButton(
          onPressed: controller.increment,
          icon: const Icon(Icons.add_circle),
          color: AppColors.pink600,
          tooltip: loc.increaseQuantity,
        ),
      ],
    );
  }
}

class _OptionGroup extends StatelessWidget {
  const _OptionGroup({
    required this.group,
    required this.controller,
    required this.loc,
  });

  final ProductOptionGroup group;
  final ProductDetailController controller;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(group.name, style: text.labelLarge),
        const SizedBox(height: 4),
        for (final option in group.options)
          InkWell(
            onTap: () => controller.toggleOption(option.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    controller.isSelected(option.id)
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    color: AppColors.pink600,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(option.name, style: text.bodyMedium)),
                  Text(
                    option.priceDeltaCents > 0
                        ? '+ ${Money.format(option.priceDeltaCents)}'
                        : loc.optionIncluded,
                    style: text.bodySmall?.copyWith(
                      color: context.surfaces.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
