import 'package:flutter/material.dart';

import '../../../core/error/api_codes.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/catalogue_controller.dart';
import '../data/catalogue_repository.dart';
import '../data/mock_catalogue_repository.dart';
import 'product_detail_page.dart';
import 'widgets/category_selector.dart';
import 'widgets/product_card.dart';

/// Onglet Commander : catalogue produits filtrable par catégorie.
class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key, this.repository});

  /// Injectable pour les tests (défaut : mock).
  final CatalogueRepository? repository;

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
    _controller.load();
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
      appBar: AppBar(title: Text(loc.navOrder)),
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
                          return ProductCard(
                            product: product,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ProductDetailPage(
                                  productId: product.id,
                                  repository: widget.repository,
                                ),
                              ),
                            ),
                            onAddToCart: product.available
                                ? () => ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            loc.addToCartComingSoon,
                                          ),
                                        ),
                                      )
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
