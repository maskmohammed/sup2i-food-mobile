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
    useSafeArea: true,
    backgroundColor: Colors.transparent,
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

  void _applyEditPrefill(ProductDetail detail) {
    if (_prefilled || widget.editLine == null) return;

    _prefilled = true;
    final line = widget.editLine!;
    final names = (line.optionsLabel ?? '')
        .split(', ')
        .where((value) => value.isNotEmpty)
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

    if (widget.editLine != null) {
      cart.remove(widget.editLine!.id);
    }

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
    final loc = AppLocalizations.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.84,
      ),
      decoration: BoxDecoration(
        color: context.surfaces.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final detail = controller.detail;

              if (detail == null) {
                return const SizedBox(
                  height: 190,
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
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.surfaces.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    detail.product.name,
                    key: const Key('product_options_title'),
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.totalIndicativeNote,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 18),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _QuantityRow(controller: controller, loc: loc),
                          for (final group in detail.optionGroups)
                            _OptionGroup(
                              group: group,
                              controller: controller,
                              loc: loc,
                            ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      key: const Key('product_options_confirm'),
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
      children: <Widget>[
        Expanded(
          child: Text(
            loc.quantityLabel,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 17),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.surfaces.background,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: controller.decrement,
                tooltip: loc.decreaseQuantity,
                icon: const Icon(Icons.remove_rounded),
                color: AppColors.navy900,
              ),
              Text(
                '${controller.quantity}',
                semanticsLabel: '${loc.quantityLabel} : ${controller.quantity}',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: controller.increment,
                tooltip: loc.increaseQuantity,
                icon: const Icon(Icons.add_rounded),
                color: AppColors.pink600,
              ),
            ],
          ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            group.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 10),
          for (final option in group.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: controller.isSelected(option.id)
                    ? AppColors.softPink
                    : context.surfaces.background,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () => controller.toggleOption(option.id),
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          controller.isSelected(option.id)
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: controller.isSelected(option.id)
                              ? AppColors.pink600
                              : AppColors.muted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          option.priceDeltaCents > 0
                              ? '+ ${Money.format(option.priceDeltaCents)}'
                              : loc.optionIncluded,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.surfaces.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
