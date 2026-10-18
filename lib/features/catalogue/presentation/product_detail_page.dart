import 'package:flutter/material.dart';

import '../../../app/cart_scope.dart';
import '../../../app/favorites_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/format/money.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/product_detail_controller.dart';
import '../data/catalogue_repository.dart';
import '../data/mock_catalogue_repository.dart';
import '../domain/product_detail.dart';
import 'widgets/loading_skeletons.dart';
import 'widgets/product_image.dart';

/// Final food-first product details screen.
///
/// Price, availability and option data remain server/repository authority.
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.repository,
  });

  final String productId;
  final CatalogueRepository? repository;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProductDetailController(
      widget.repository ?? const MockCatalogueRepository(),
    );
    _controller.load(widget.productId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('product_detail_screen'),
      backgroundColor: context.surfaces.background,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final detail = _controller.detail;

          if (_controller.isLoading && detail == null) {
            return const SafeArea(child: ProductDetailSkeleton());
          }

          if (_controller.errorCode != null && detail == null) {
            return SafeArea(
              child: AppStateView.error(
                title: loc.errorMessage(
                  _controller.errorCode ?? ApiCodes.internalError,
                ),
                message: '',
                actionLabel: loc.retry,
                onAction: () => _controller.load(widget.productId),
              ),
            );
          }

          return _DetailBody(detail: detail!, controller: _controller);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail, required this.controller});

  final ProductDetail detail;
  final ProductDetailController controller;

  void _addToCart(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final product = detail.product;

    AppHaptics.light();
    CartScope.of(context, listen: false).addItem(
      productId: product.id,
      name: product.name,
      unitPriceCents: controller.indicativeUnitPriceCents,
      quantity: controller.quantity,
      optionsLabel: controller.selectedOptionsLabel,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.addedToCart)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final product = detail.product;
    final indicativeTotal =
        controller.indicativeUnitPriceCents * controller.quantity;

    return Stack(
      children: <Widget>[
        CustomScrollView(
          key: const Key('product_detail_scroll'),
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 310,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.neutral0,
              foregroundColor: AppColors.navy900,
              surfaceTintColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: _RoundAction(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _RoundAction(
                    icon: FavoritesScope.of(context).isFavorite(product.id)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    onTap: () => FavoritesScope.of(
                      context,
                      listen: false,
                    ).toggle(product.id),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                  child: ProductImage(query: product.name, iconSize: 72),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 132),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            product.name,
                            key: const Key('product_detail_name'),
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(fontSize: 26),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          Money.format(product.priceCents),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.pink600,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    if (product.description != null) ...<Widget>[
                      const SizedBox(height: 10),
                      Text(
                        product.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        if (detail.prepMinutes != null)
                          _MetaChip(
                            icon: Icons.schedule_rounded,
                            label: '${detail.prepMinutes} ${loc.minutesSuffix}',
                          ),
                        _MetaChip(
                          icon: product.available
                              ? Icons.check_circle_outline_rounded
                              : Icons.remove_circle_outline_rounded,
                          label: product.available
                              ? 'Disponible'
                              : loc.productUnavailable,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _QuantityBlock(controller: controller),
                    if (product.allergens.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 28),
                      _SectionTitle(title: loc.allergensLabel),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          for (final allergen in product.allergens)
                            Chip(
                              avatar: const Icon(
                                Icons.info_outline_rounded,
                                size: 17,
                                color: AppColors.pink600,
                              ),
                              label: Text(allergen),
                              backgroundColor: AppColors.softPink,
                              side: const BorderSide(color: Color(0x33E6318C)),
                              shape: const StadiumBorder(),
                            ),
                        ],
                      ),
                    ],
                    for (final group in detail.optionGroups)
                      _OptionGroupView(group: group, controller: controller),
                    if (detail.note != null) ...<Widget>[
                      const SizedBox(height: 28),
                      _InfoNote(text: detail.note!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _StickyAddBar(
            enabled: product.available,
            total: Money.format(indicativeTotal),
            label: loc.addToCart,
            onTap: () => _addToCart(context),
          ),
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neutral0,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: const Color(0x24161B5C),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: AppColors.navy900, size: 22),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaces.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.surfaces.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: AppColors.blue600),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.navy900),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontSize: 18, color: AppColors.navy900),
    );
  }
}

class _QuantityBlock extends StatelessWidget {
  const _QuantityBlock({required this.controller});

  final ProductDetailController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Row(
      children: <Widget>[
        Expanded(child: _SectionTitle(title: loc.quantityLabel)),
        Container(
          decoration: BoxDecoration(
            color: context.surfaces.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.surfaces.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                tooltip: loc.decreaseQuantity,
                onPressed: controller.decrement,
                icon: const Icon(Icons.remove_rounded),
                color: AppColors.navy900,
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '${controller.quantity}',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: loc.increaseQuantity,
                onPressed: controller.increment,
                icon: const Icon(Icons.add_rounded),
                color: AppColors.neutral0,
                style: IconButton.styleFrom(backgroundColor: AppColors.pink600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionGroupView extends StatelessWidget {
  const _OptionGroupView({required this.group, required this.controller});

  final ProductOptionGroup group;
  final ProductDetailController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionTitle(title: group.name),
          const SizedBox(height: 10),
          for (final option in group.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Material(
                color: controller.isSelected(option.id)
                    ? AppColors.softPink
                    : context.surfaces.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => controller.toggleOption(option.id),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: controller.isSelected(option.id)
                            ? AppColors.pink600
                            : context.surfaces.border,
                      ),
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
                              ?.copyWith(color: AppColors.muted),
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

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.blue600,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.navy900),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyAddBar extends StatelessWidget {
  const _StickyAddBar({
    required this.enabled,
    required this.total,
    required this.label,
    required this.onTap,
  });

  final bool enabled;
  final String total;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaces.surface,
      elevation: 10,
      shadowColor: const Color(0x24161B5C),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: SizedBox(
            height: 54,
            child: FilledButton(
              key: const Key('product_detail_add'),
              onPressed: enabled ? onTap : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(label),
                  const SizedBox(width: 8),
                  const Text('·'),
                  const SizedBox(width: 8),
                  Text(total),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
