import 'package:flutter/material.dart';

import '../../../app/auth_guard.dart';
import '../../../app/favorites_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/widgets/cart_button.dart';
import '../../catalogue/application/catalogue_controller.dart';
import '../../catalogue/data/catalogue_repository.dart';
import '../../catalogue/data/mock_catalogue_repository.dart';
import '../../catalogue/domain/product.dart';
import '../../catalogue/presentation/catalogue_page.dart';
import '../../catalogue/presentation/product_detail_page.dart';
import '../../catalogue/presentation/search_page.dart';
import '../../catalogue/presentation/widgets/category_selector.dart';
import '../../catalogue/presentation/widgets/product_card.dart';
import '../../catalogue/presentation/widgets/product_options_sheet.dart';

/// Onglet Accueil : mise en avant (coups de cœur, catégories, produits).
/// Réutilise le catalogue ; sert de point d'entrée vers Commander et le détail.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.repository});

  final CatalogueRepository? repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CatalogueController _controller;
  late final CatalogueRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? const MockCatalogueRepository();
    _controller = CatalogueController(_repository)..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openCatalogue([String? categoryId]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CataloguePage(
          repository: widget.repository,
          initialCategoryId: categoryId,
        ),
      ),
    );
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

  void _addToCart(Product product, AppLocalizations loc) {
    // Action protégée (mode invité) : mur de connexion avant tout ajout.
    if (!AuthGuard.require(context, message: loc.loginWallCartMessage)) return;
    // Ouvre la feuille de personnalisation (quantité + options) avant l'ajout.
    showProductOptionsSheet(
      context,
      productId: product.id,
      productName: product.name,
      repository: widget.repository,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.homeWelcome),
        actions: const [CartButton()],
      ),
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

          final products = _controller.products;
          final favourites = products.take(3).toList();
          final favorites = FavoritesScope.of(context);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SearchBar(hint: loc.homeSearchHint, onTap: _openSearch),
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: loc.homeFavorites),
              SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: favourites.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = favourites[index];
                    return SizedBox(
                      width: 160,
                      child: ProductCard(
                        product: product,
                        isFavorite: favorites.isFavorite(product.id),
                        onFavoriteTap: () => favorites.toggle(product.id),
                        onTap: () => _openDetail(product),
                        onAddToCart: product.available
                            ? () => _addToCart(product, loc)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: loc.homeCategories),
              CategorySelector(
                categories: _controller.categories,
                selectedId: null,
                onSelect: (categoryId) => _openCatalogue(categoryId),
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: loc.homeProducts,
                actionLabel: loc.seeMore,
                onAction: _openCatalogue,
              ),
              GridView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                    isFavorite: favorites.isFavorite(product.id),
                    onFavoriteTap: () => favorites.toggle(product.id),
                    onTap: () => _openDetail(product),
                    onAddToCart: product.available
                        ? () => _addToCart(product, loc)
                        : null,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.surfaces.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.surfaces.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.muted),
            const SizedBox(width: 8),
            Text(
              hint,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: text.titleLarge),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
