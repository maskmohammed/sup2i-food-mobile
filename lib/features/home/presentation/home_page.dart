import 'package:flutter/material.dart';

import '../../../app/app_bar_actions.dart';
import '../../../app/auth_scope.dart';
import '../../../app/favorites_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../core/widgets/brand_chef_mascot.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalogue/application/catalogue_controller.dart';
import '../../catalogue/data/catalogue_repository.dart';
import '../../catalogue/data/mock_catalogue_repository.dart';
import '../../catalogue/domain/category.dart';
import '../../catalogue/domain/product.dart';
import '../../catalogue/presentation/catalogue_page.dart';
import '../../catalogue/presentation/product_detail_page.dart';
import '../../catalogue/presentation/search_page.dart';
import '../../catalogue/presentation/widgets/category_icons.dart';
import '../../catalogue/presentation/widgets/product_card.dart';
import '../../catalogue/presentation/widgets/product_options_sheet.dart';

/// Final student Home composition.
///
/// Business data remains repository-driven. The presentation follows the
/// SUP2I FOOD charter and the locked food-app visual reference.
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
    final session = AuthScope.of(context).session;
    final displayName = session?.displayName.trim().isNotEmpty == true
        ? session!.displayName.trim()
        : 'Étudiant SUP2I';

    return Scaffold(
      backgroundColor: context.surfaces.background,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.products.isEmpty) {
            return const SafeArea(child: AppLoadingView());
          }

          if (_controller.errorCode != null && _controller.products.isEmpty) {
            return SafeArea(
              child: AppStateView.error(
                title: loc.errorMessage(
                  _controller.errorCode ?? ApiCodes.internalError,
                ),
                message: '',
                actionLabel: loc.retry,
                onAction: _controller.load,
              ),
            );
          }

          final products = _controller.products;
          final highlights = products.take(4).toList();
          final favorites = FavoritesScope.of(context);

          return RefreshIndicator(
            color: AppColors.pink600,
            onRefresh: _controller.load,
            child: ListView(
              key: const Key('home_scroll'),
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                _BrandHeader(
                  displayName: displayName,
                  welcome: loc.homeWelcome,
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SearchBar(
                    hint: loc.homeSearchHint,
                    onTap: _openSearch,
                  ),
                ),
                const SizedBox(height: 18),
                _HeroBanner(onTap: _openCatalogue),
                const SizedBox(height: 26),
                _SectionHeader(
                  title: loc.homeCategories,
                  actionLabel: loc.seeMore,
                  onAction: _openCatalogue,
                ),
                _HomeCategoryStrip(
                  categories: _controller.categories,
                  allLabel: loc.catalogueAll,
                  onSelect: _openCatalogue,
                ),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: loc.homeFavorites,
                  actionLabel: loc.seeMore,
                  onAction: _openCatalogue,
                ),
                SizedBox(
                  height: 244,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: highlights.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final product = highlights[index];

                      return SizedBox(
                        width: 176,
                        child: ProductCard(
                          product: product,
                          isFavorite: favorites.isFavorite(product.id),
                          onFavoriteTap: () => favorites.toggle(product.id),
                          onTap: () => _openDetail(product),
                          onAddToCart: product.available
                              ? () => _addToCart(product)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: loc.homeProducts,
                  actionLabel: loc.seeMore,
                  onAction: _openCatalogue,
                ),
                GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.70,
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
                          ? () => _addToCart(product)
                          : null,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.displayName, required this.welcome});

  final String displayName;
  final String welcome;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home_brand_header'),
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.navy900, AppColors.blue600],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.neutral0,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                'assets/images/sup2i_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.restaurant_menu_rounded,
                    color: AppColors.pink600,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    welcome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral0.withValues(alpha: 0.76),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayName,
                    key: const Key('home_student_name'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.neutral0,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.neutral0,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const AppBarActions(),
            ),
          ],
        ),
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
    return Material(
      color: context.surfaces.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: const Key('home_search'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.surfaces.border),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.search_rounded, color: AppColors.navy900),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hint,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.softPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: AppColors.pink600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home_hero_banner'),
      height: 184,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.navy900, AppColors.blue600],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x24161B5C),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -34,
            top: -54,
            child: Container(
              width: 166,
              height: 166,
              decoration: BoxDecoration(
                color: AppColors.pink600.withValues(alpha: 0.94),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            right: 0,
            bottom: -7,
            child: BrandChefMascot(width: 142, height: 160),
          ),
          Positioned(
            left: 20,
            top: 22,
            right: 142,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'SUP2I FOOD',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.pink600,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bien manger.\nMieux étudier.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.neutral0,
                    height: 1.04,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: FilledButton(
                    key: const Key('home_hero_action'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.neutral0,
                      foregroundColor: AppColors.navy900,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: onTap,
                    child: const Text('Voir le Snack'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCategoryStrip extends StatelessWidget {
  const _HomeCategoryStrip({
    required this.categories,
    required this.allLabel,
    required this.onSelect,
  });

  final List<Category> categories;
  final String allLabel;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final entries = <_CategoryEntry>[
      _CategoryEntry(id: null, name: allLabel, icon: categoryIcon(null)),
      ...categories.map(
        (category) => _CategoryEntry(
          id: category.id,
          name: category.name,
          icon: categoryIcon(category.id),
        ),
      ),
    ];

    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final entry = entries[index];

          return InkWell(
            onTap: () => onSelect(entry.id),
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 68,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: context.surfaces.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.surfaces.border),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x10161B5C),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(entry.icon, color: AppColors.pink600, size: 27),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.surfaces.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryEntry {
  const _CategoryEntry({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String? id;
  final String name;
  final IconData icon;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 19),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
