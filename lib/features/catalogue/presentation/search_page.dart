import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/cart_scope.dart';
import '../../../app/favorites_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../data/catalogue_repository.dart';
import '../data/mock_catalogue_repository.dart';
import '../data/search_history_store.dart';
import '../domain/product.dart';
import 'product_detail_page.dart';
import 'widgets/product_card.dart';

/// Écran de recherche dédié : champ éditable (autofocus), filtre les produits
/// par nom (insensible à la casse) au fil de la saisie. État vide « Aucun
/// résultat » réutilisé du design. Historique des 5 dernières recherches
/// proposé quand le champ est vide.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.repository, this.historyStore});

  /// Injectable pour les tests (défaut : mock).
  final CatalogueRepository? repository;

  /// Historique local (défaut : shared_preferences).
  final SearchHistoryStore? historyStore;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final CatalogueRepository _repository;
  late final SearchHistoryStore _historyStore;
  final TextEditingController _field = TextEditingController();

  List<Product> _all = const <Product>[];
  List<String> _recent = const <String>[];
  bool _loading = true;
  String? _errorCode;
  String _query = ''; // terme filtrant (débounced)
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? const MockCatalogueRepository();
    _historyStore =
        widget.historyStore ?? SharedPreferencesSearchHistoryStore();
    _loadAll();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final terms = await _historyStore.load();
    if (!mounted) return;
    setState(() => _recent = terms);
  }

  void _record(String term) {
    final updated = mergeRecentSearch(_recent, term);
    if (updated == _recent) return;
    setState(() => _recent = updated);
    _historyStore.save(updated);
  }

  /// Débounce : ne filtre qu'après une courte pause de frappe (charte).
  void _onChanged(String value) {
    _debounce?.cancel();
    // Rebuild immédiat pour le bouton « effacer » (basé sur _field.text).
    setState(() {});
    _debounce = Timer(AppMotion.searchDebounce, () {
      if (mounted) setState(() => _query = value);
    });
  }

  void _submit(String value) {
    _debounce?.cancel();
    setState(() => _query = value);
    _record(value);
  }

  void _applyRecent(String term) {
    _debounce?.cancel();
    _field.text = term;
    _field.selection = TextSelection.collapsed(offset: term.length);
    setState(() => _query = term);
  }

  void _clearField() {
    _debounce?.cancel();
    _field.clear();
    setState(() => _query = '');
  }

  Future<void> _clearHistory() async {
    setState(() => _recent = const <String>[]);
    await _historyStore.save(const <String>[]);
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
    _debounce?.cancel();
    _field.dispose();
    super.dispose();
  }

  List<Product> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const <Product>[];
    return _all.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  void _openDetail(Product product) {
    _record(_query);
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
          onChanged: _onChanged,
          onSubmitted: _submit,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: loc.homeSearchHint,
          ),
        ),
        actions: [
          if (_field.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: loc.searchClear,
              onPressed: _clearField,
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
      if (_recent.isEmpty) return _Prompt(text: loc.searchPrompt);
      return _RecentSearches(
        terms: _recent,
        onSelect: _applyRecent,
        onClear: _clearHistory,
      );
    }
    final results = _results;
    if (results.isEmpty) {
      return AppStateView.empty(
        icon: Icons.search_off,
        title: loc.searchNoResultsFor(_query.trim()),
        message: loc.searchNoResultsHint,
        actionLabel: loc.searchSeeAllCatalogue,
        onAction: _clearField,
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

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.terms,
    required this.onSelect,
    required this.onClear,
  });

  final List<String> terms;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.searchRecentTitle,
                style: text.labelLarge?.copyWith(color: AppColors.muted),
              ),
              TextButton(
                onPressed: onClear,
                child: Text(loc.searchClearHistory),
              ),
            ],
          ),
        ),
        for (final term in terms)
          ListTile(
            leading: const Icon(Icons.history, color: AppColors.muted),
            title: Text(term),
            onTap: () => onSelect(term),
          ),
      ],
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
