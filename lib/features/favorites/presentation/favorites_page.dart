import 'package:flutter/material.dart';

import '../../../app/auth_guard.dart';
import '../../../app/cart_scope.dart';
import '../../../app/favorites_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalogue/application/catalogue_controller.dart';
import '../../catalogue/data/catalogue_repository.dart';
import '../../catalogue/data/mock_catalogue_repository.dart';
import '../../catalogue/domain/product.dart';
import '../../catalogue/presentation/product_detail_page.dart';
import '../../catalogue/presentation/widgets/product_card.dart';

/// Écran « Mes favoris » : produits marqués (client-side pour l'instant).
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, this.repository});

  final CatalogueRepository? repository;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final CatalogueController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CatalogueController(
      widget.repository ?? const MockCatalogueRepository(),
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addToCart(Product product, AppLocalizations loc) {
    if (!AuthGuard.require(context, message: loc.loginWallCartMessage)) return;
    CartScope.of(context, listen: false).addItem(
      productId: product.id,
      name: product.name,
      unitPriceCents: product.priceCents,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.addedToCart)));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final favorites = FavoritesScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.favoritesTitle)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.products.isEmpty) {
            return const AppLoadingView();
          }
          if (_controller.errorCode != null && _controller.products.isEmpty) {
            return AppStateView.error(
              title: loc.errorMessage(
                _controller.errorCode ?? ApiCodes.internalError,
              ),
              message: '',
              actionLabel: loc.retry,
              onAction: _controller.load,
            );
          }
          final products = _controller.products
              .where((p) => favorites.isFavorite(p.id))
              .toList();
          if (products.isEmpty) {
            return AppStateView.empty(
              icon: Icons.favorite_border,
              title: loc.favoritesEmpty,
              message: '',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                isFavorite: true,
                onFavoriteTap: () => favorites.toggle(product.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProductDetailPage(
                      productId: product.id,
                      repository: widget.repository,
                    ),
                  ),
                ),
                onAddToCart: product.available
                    ? () => _addToCart(product, loc)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
