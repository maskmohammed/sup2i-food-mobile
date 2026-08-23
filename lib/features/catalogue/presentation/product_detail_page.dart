import 'package:flutter/material.dart';

import '../../../app/cart_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/format/money.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/widgets/cart_button.dart';
import '../application/product_detail_controller.dart';
import '../data/catalogue_repository.dart';
import '../data/mock_catalogue_repository.dart';
import '../domain/product_detail.dart';
import 'widgets/loading_skeletons.dart';
import 'widgets/product_image.dart';

/// Écran détail produit : image, prix, durée, quantité, allergènes (chips
/// texte), groupes d'options, note. Le total reste autorité serveur ; l'ajout
/// au panier arrive en M4.
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.repository,
  });

  final String productId;

  /// Injectable pour les tests (défaut : mock).
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
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Text(_controller.detail?.product.name ?? ''),
        ),
        actions: const [CartButton()],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final detail = _controller.detail;
          if (_controller.isLoading && detail == null) {
            return const ProductDetailSkeleton();
          }
          if (_controller.errorCode != null && detail == null) {
            return AppStateView.error(
              title: loc.errorMessage(
                _controller.errorCode ?? ApiCodes.internalError,
              ),
              message: '',
              actionLabel: loc.retry,
              onAction: () => _controller.load(widget.productId),
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final product = detail.product;

    return ListView(
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: ProductImage(query: product.name, iconSize: 56),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(product.name, style: text.headlineSmall),
                  ),
                  Text(
                    Money.format(product.priceCents),
                    style: text.headlineSmall?.copyWith(
                      color: AppColors.pink600,
                    ),
                  ),
                ],
              ),
              if (product.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  product.description!,
                  style: text.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ],
              if (detail.prepMinutes != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 18,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${detail.prepMinutes} ${loc.minutesSuffix}',
                      style: text.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _QuantityStepper(controller: controller),
              if (product.allergens.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(loc.allergensLabel, style: text.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in product.allergens)
                      Chip(
                        label: Text(a),
                        backgroundColor: context.surfaces.background,
                        side: BorderSide(color: context.surfaces.border),
                      ),
                  ],
                ),
              ],
              for (final group in detail.optionGroups)
                _OptionGroupView(group: group, controller: controller),
              if (detail.note != null) ...[
                const SizedBox(height: 20),
                _InfoNote(text: detail.note!),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
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
                  },
                  child: Text(loc.addToCart),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.controller});

  final ProductDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.surfaces.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: controller.decrement,
            icon: const Icon(Icons.remove),
            color: AppColors.navy900,
          ),
          Text('${controller.quantity}'),
          IconButton(
            onPressed: controller.increment,
            icon: const Icon(Icons.add),
            color: AppColors.pink600,
          ),
        ],
      ),
    );
  }
}

class _OptionGroupView extends StatelessWidget {
  const _OptionGroupView({required this.group, required this.controller});

  final ProductOptionGroup group;
  final ProductDetailController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(group.name, style: text.labelLarge),
        const SizedBox(height: 4),
        for (final option in group.options)
          Row(
            children: [
              Expanded(child: Text(option.name, style: text.bodyMedium)),
              Text(
                option.priceDeltaCents > 0
                    ? '+ ${Money.format(option.priceDeltaCents)}'
                    : loc.optionIncluded,
                style: text.bodySmall?.copyWith(color: AppColors.muted),
              ),
              IconButton(
                onPressed: () => controller.toggleOption(option.id),
                icon: Icon(
                  controller.isSelected(option.id)
                      ? Icons.check_circle
                      : Icons.add_circle_outline,
                ),
                color: AppColors.pink600,
              ),
            ],
          ),
      ],
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x14E6318C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20, color: AppColors.pink600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.neutral900),
            ),
          ),
        ],
      ),
    );
  }
}
