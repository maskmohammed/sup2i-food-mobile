import 'package:flutter/material.dart';

import '../../../app/cart_scope.dart';
import '../../../app/favorites_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../data/catalogue_repository.dart';
import '../data/mock_catalogue_repository.dart';
import '../domain/product.dart';
import 'product_detail_page.dart';
import 'widgets/product_card.dart';

/// Écran de recherche dédié : champ éditable (autofocus), filtre les produits
/// par nom (insensible à la casse) au fil de la saisie. État vide « Aucun
/// résultat » réutilisé du design.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.repository});

  /// Injectable pour les tests (défaut : mock).
  final CatalogueRepository? repository;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final CatalogueRepository _repository;
  final TextEditingController _field = TextEditingController();

  List<Product> _all = const <Product>[];
  bool _loading = true;
  String? _errorCode;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? const MockCatalogueRepository();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _errorCode = null;
    });
    try {
      final products = await _repository.products();
      if (!mounted) return;
      setState(() {
        _all = products;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _errorCode = ApiCodes.internalError;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  List<Product> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const <Product>[];
    return _all.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProductDetailPage(productId: product.id, repository: _repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _field,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: loc.homeSearchHint,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: loc.searchClear,
              onPressed: () => setState(() {
                _field.clear();
                _query = '';
              }),
            ),
        ],
      ),
      body: _buildBody(loc),
    );
  }

  Widget _buildBody(AppLocalizations loc) {
    if (_loading) return const AppLoadingView();
    if (_errorCode != null) {
      return AppStateView.error(
        title: loc.errorMessage(_errorCode ?? ApiCodes.internalError),
        message: '',
        actionLabel: loc.retry,
        onAction: _loadAll,
      );
    }
    if (_query.trim().isEmpty) {
      return _Prompt(text: loc.searchPrompt);
    }
    final results = _results;
    if (results.isEmpty) {
      return AppStateView.empty(
        icon: Icons.search_off,
        title: loc.searchNoResultsTitle,
        message: loc.searchNoResultsHint,
        actionLabel: loc.searchSeeAllCatalogue,
        onAction: () => setState(() {
          _field.clear();
          _query = '';
        }),
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
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        final favorites = FavoritesScope.of(context);
        return ProductCard(
          product: product,
          isFavorite: favorites.isFavorite(product.id),
          onFavoriteTap: () => favorites.toggle(product.id),
          onTap: () => _openDetail(product),
          onAddToCart: product.available
              ? () {
                  CartScope.of(context, listen: false).addItem(
                    productId: product.id,
                    name: product.name,
                    unitPriceCents: product.priceCents,
                  );
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(loc.addedToCart)));
                }
              : null,
        );
      },
    );
  }
}

class _Prompt extends StatelessWidget {
  const _Prompt({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 40, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
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
