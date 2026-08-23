import 'package:flutter/material.dart';

import '../../../app/cart_scope.dart';
import '../../../app/favorites_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/widgets/cart_button.dart';
import '../application/catalogue_controller.dart';
import '../data/catalogue_repository.dart';
import '../data/mock_catalogue_repository.dart';
import 'product_detail_page.dart';
import 'widgets/category_selector.dart';
import 'widgets/loading_skeletons.dart';
import 'widgets/product_card.dart';

/// Onglet Commander : catalogue produits filtrable par catégorie.
class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key, this.repository, this.initialCategoryId});

  /// Injectable pour les tests (défaut : mock).
  final CatalogueRepository? repository;

  /// Catégorie présélectionnée à l'ouverture (ex. depuis l'Accueil).
  final String? initialCategoryId;

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  late final CatalogueController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CatalogueController(
      widget.repository ?? const MockCatalogueRepository(),
    );
    _controller.load(categoryId: widget.initialCategoryId);
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
      appBar: AppBar(title: Text(loc.navOrder), actions: const [CartButton()]),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.products.isEmpty) {
            return const CatalogueSkeleton();
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
          return Column(
            children: [
              const SizedBox(height: 12),
              CategorySelector(
                categories: _controller.categories,
                selectedId: _controller.selectedCategoryId,
                onSelect: _controller.selectCategory,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _controller.products.isEmpty
                    ? AppStateView.empty(
                        icon: Icons.inventory_2_outlined,
                        title: loc.catalogueEmpty,
                        message: '',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.72,
                            ),
                        itemCount: _controller.products.length,
                        itemBuilder: (context, index) {
                          final product = _controller.products[index];
                          final favorites = FavoritesScope.of(context);
                          return ProductCard(
                            product: product,
                            isFavorite: favorites.isFavorite(product.id),
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
                                ? () {
                                    CartScope.of(
                                      context,
                                      listen: false,
                                    ).addItem(
                                      productId: product.id,
                                      name: product.name,
                                      unitPriceCents: product.priceCents,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(loc.addedToCart)),
                                    );
                                  }
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
