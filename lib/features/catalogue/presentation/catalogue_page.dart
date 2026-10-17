import 'package:flutter/material.dart';

import '../../../app/app_bar_actions.dart';
import '../../../app/favorites_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/catalogue_controller.dart';
import '../data/catalogue_repository.dart';
import '../data/mock_catalogue_repository.dart';
import '../domain/product.dart';
import 'product_detail_page.dart';
import 'search_page.dart';
import 'widgets/category_selector.dart';
import 'widgets/loading_skeletons.dart';
import 'widgets/product_card.dart';
import 'widgets/product_options_sheet.dart';

/// Final Snack catalogue.
///
/// Data and business rules remain repository-driven. This screen only owns the
/// visual composition and interaction patterns.
class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key, this.repository, this.initialCategoryId});

  final CatalogueRepository? repository;
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

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchPage(repository: widget.repository),
      ),
    );
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailPage(
          productId: product.id,
          repository: widget.repository,
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    showProductOptionsSheet(
      context,
      productId: product.id,
      productName: product.name,
      repository: widget.repository,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('snack_screen'),
      backgroundColor: context.surfaces.background,
      body: SafeArea(
        child: ListenableBuilder(
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _SnackHeader(
                  title: loc.navOrder,
                  searchHint: loc.homeSearchHint,
                  onSearch: _openSearch,
                ),
                const SizedBox(height: 18),
                CategorySelector(
                  categories: _controller.categories,
                  selectedId: _controller.selectedCategoryId,
                  onSelect: _controller.selectCategory,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _controller.selectedCategoryId == null
                              ? 'Tous les produits'
                              : 'Selection du moment',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontSize: 19),
                        ),
                      ),
                      _ResultBadge(count: _controller.products.length),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _controller.products.isEmpty
                      ? AppStateView.empty(
                          icon: Icons.restaurant_menu_rounded,
                          title: loc.catalogueEmpty,
                          message: '',
                        )
                      : RefreshIndicator(
                          color: AppColors.pink600,
                          onRefresh: _controller.load,
                          child: GridView.builder(
                            key: const Key('snack_product_grid'),
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 0.70,
                                ),
                            itemCount: _controller.products.length,
                            itemBuilder: (context, index) {
                              final product = _controller.products[index];
                              final favorites = FavoritesScope.of(context);

                              return ProductCard(
                                product: product,
                                isFavorite: favorites.isFavorite(product.id),
                                onFavoriteTap: () =>
                                    favorites.toggle(product.id),
                                onTap: () => _openDetail(product),
                                onAddToCart: product.available
                                    ? () => _addToCart(product)
                                    : null,
                              );
                            },
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

class _SnackHeader extends StatelessWidget {
  const _SnackHeader({
    required this.title,
    required this.searchHint,
    required this.onSearch,
  });

  final String title;
  final String searchHint;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('snack_header'),
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 22),
      decoration: const BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x10161B5C),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.navy900, fontSize: 26),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choisissez, personnalisez, profitez.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const AppBarActions(),
            ],
          ),
          const SizedBox(height: 18),
          Material(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              key: const Key('snack_search'),
              onTap: onSearch,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.search_rounded, color: AppColors.navy900),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        searchHint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: AppColors.pink600,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.pink600,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
