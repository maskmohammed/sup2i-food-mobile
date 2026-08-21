import 'package:flutter/material.dart';

import '../../../../core/format/money.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_surfaces.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/product.dart';

/// Carte produit du catalogue (image, nom, prix DH, favori, ajout panier).
/// Un produit indisponible est grisé + badge « Indisponible » (statut jamais
/// signalé par la couleur seule).
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Opacity(
      opacity: product.available ? 1 : 0.6,
      child: Material(
        color: context.surfaces.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.surfaces.border),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: context.surfaces.background,
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: AppColors.muted,
                        size: 36,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 22,
                            color: AppColors.pink500,
                          ),
                        ),
                      ),
                    ),
                    if (!product.available)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _Badge(label: loc.productUnavailable),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Money.format(product.priceCents),
                            style: text.labelLarge?.copyWith(
                              color: context.surfaces.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: product.available ? onAddToCart : null,
                      icon: const Icon(Icons.add_circle),
                      color: AppColors.pink600,
                      tooltip: loc.addToCartComingSoon,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.neutral0),
      ),
    );
  }
}
