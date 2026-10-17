import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/favorites_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../data/catalogue_repository.dart';
import '../data/mock_catalogue_repository.dart';
import '../data/search_history_store.dart';
import '../domain/product.dart';
import 'product_detail_page.dart';
import 'widgets/product_card.dart';
import 'widgets/product_options_sheet.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.repository, this.historyStore});

  final CatalogueRepository? repository;
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
  String _query = '';
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

  void _record(String term) {
    final updated = mergeRecentSearch(_recent, term);
    if (updated == _recent) return;
    setState(() => _recent = updated);
    _historyStore.save(updated);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() {});
    _debounce = Timer(AppMotion.searchDebounce, () {
      if (mounted) {
        setState(() => _query = value);
      }
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

  void _applySuggestion(String name) {
    _debounce?.cancel();
    _field.text = name;
    _field.selection = TextSelection.collapsed(offset: name.length);
    setState(() => _query = name);
    _record(name);
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

  List<String> _suggestionsFor(String raw) {
    final q = raw.toLowerCase();
    final names = <String>[];

    for (final product in _all) {
      if (product.name.toLowerCase().contains(q) &&
          !names.contains(product.name)) {
        names.add(product.name);
        if (names.length >= 5) break;
      }
    }

    return names;
  }

  List<Product> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const <Product>[];

    return _all
        .where((product) => product.name.toLowerCase().contains(q))
        .toList();
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

  void _addToCart(Product product) {
    showProductOptionsSheet(
      context,
      productId: product.id,
      productName: product.name,
      repository: _repository,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('search_screen'),
      backgroundColor: context.surfaces.background,
      appBar: AppBar(
        toolbarHeight: 78,
        titleSpacing: 4,
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: context.surfaces.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.surfaces.border),
          ),
          child: TextField(
            key: const Key('search_field'),
            controller: _field,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: _submit,
            decoration: InputDecoration(
              hintText: loc.homeSearchHint,
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.navy900,
              ),
              suffixIcon: _field.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearField,
                      icon: const Icon(Icons.close_rounded),
                      tooltip: loc.searchClear,
                    ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
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

    final raw = _field.text.trim();

    if (raw.isEmpty) {
      if (_recent.isEmpty) {
        return _Prompt(text: loc.searchPrompt);
      }

      return _RecentSearches(
        terms: _recent,
        onSelect: _applyRecent,
        onClear: _clearHistory,
      );
    }

    final pending = raw.toLowerCase() != _query.trim().toLowerCase();

    if (pending) {
      final suggestions = _suggestionsFor(raw);

      if (suggestions.isEmpty) {
        return const SizedBox.shrink();
      }

      return _Suggestions(terms: suggestions, onSelect: _applySuggestion);
    }

    final results = _results;

    if (results.isEmpty) {
      return AppStateView.empty(
        icon: Icons.search_off_rounded,
        title: loc.searchNoResultsFor(_query.trim()),
        message: loc.searchNoResultsHint,
        actionLabel: loc.searchSeeAllCatalogue,
        onAction: _clearField,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Semantics(
            liveRegion: true,
            child: Text(
              loc.searchResultsCount(results.length),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(child: _resultsGrid(results)),
      ],
    );
  }

  Widget _resultsGrid(List<Product> results) {
    return GridView.builder(
      key: const Key('search_results_grid'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.70,
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
          onAddToCart: product.available ? () => _addToCart(product) : null,
        );
      },
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.terms, required this.onSelect});

  final List<String> terms;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      itemCount: terms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final term = terms[index];

        return Material(
          color: context.surfaces.surface,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            leading: const Icon(Icons.search_rounded, color: AppColors.pink600),
            title: Text(term),
            trailing: const Icon(
              Icons.north_west_rounded,
              size: 18,
              color: AppColors.muted,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onTap: () => onSelect(term),
          ),
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
    final loc = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                loc.searchRecentTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
            ),
            TextButton(onPressed: onClear, child: Text(loc.searchClearHistory)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final term in terms)
              ActionChip(
                avatar: const Icon(
                  Icons.history_rounded,
                  size: 17,
                  color: AppColors.blue600,
                ),
                label: Text(term),
                backgroundColor: context.surfaces.surface,
                side: BorderSide(color: context.surfaces.border),
                shape: const StadiumBorder(),
                onPressed: () => onSelect(term),
              ),
          ],
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
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.softPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 34,
                color: AppColors.pink600,
              ),
            ),
            const SizedBox(height: 18),
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
