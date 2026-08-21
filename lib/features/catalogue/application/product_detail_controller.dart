import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../data/catalogue_repository.dart';
import '../domain/product_detail.dart';

/// État de l'écran détail produit : chargement, quantité, options sélectionnées.
///
/// Ne calcule **aucun total** : le prix définitif est autorité serveur
/// (au panier / à la commande). Les deltas d'options sont indicatifs.
class ProductDetailController extends ChangeNotifier {
  ProductDetailController(this._repository);

  final CatalogueRepository _repository;

  bool _loading = false;
  String? _errorCode;
  ProductDetail? _detail;
  int _quantity = 1;
  final Set<String> _selectedOptionIds = <String>{};

  bool get isLoading => _loading;
  String? get errorCode => _errorCode;
  ProductDetail? get detail => _detail;
  int get quantity => _quantity;

  bool isSelected(String optionId) => _selectedOptionIds.contains(optionId);

  List<ProductOption> get selectedOptions => detail == null
      ? const <ProductOption>[]
      : detail!.optionGroups
            .expand((g) => g.options)
            .where((o) => _selectedOptionIds.contains(o.id))
            .toList();

  /// Prix unitaire **indicatif** (base + deltas d'options). Le total réel est
  /// autorité serveur.
  int get indicativeUnitPriceCents =>
      (detail?.product.priceCents ?? 0) +
      selectedOptions.fold(0, (sum, o) => sum + o.priceDeltaCents);

  String? get selectedOptionsLabel {
    final names = selectedOptions.map((o) => o.name).toList();
    return names.isEmpty ? null : names.join(', ');
  }

  Future<void> load(String productId) async {
    _loading = true;
    _errorCode = null;
    notifyListeners();
    try {
      _detail = await _repository.productDetail(productId);
    } on ApiException catch (e) {
      _errorCode = e.code;
    } catch (_) {
      _errorCode = ApiCodes.internalError;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void increment() {
    _quantity++;
    notifyListeners();
  }

  void decrement() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  void toggleOption(String optionId) {
    if (!_selectedOptionIds.add(optionId)) {
      _selectedOptionIds.remove(optionId);
    }
    notifyListeners();
  }
}
