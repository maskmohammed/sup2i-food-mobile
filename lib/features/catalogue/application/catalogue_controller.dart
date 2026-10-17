import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../data/catalogue_repository.dart';
import '../domain/category.dart';
import '../domain/product.dart';

/// État du catalogue : catégories, produits filtrés, chargement, erreur.
class CatalogueController extends ChangeNotifier {
  CatalogueController(this._repository);

  final CatalogueRepository _repository;

  bool _loading = false;
  String? _errorCode;
  List<Category> _categories = const <Category>[];
  List<Product> _products = const <Product>[];
  String? _selectedCategoryId; // null = « Tous »

  bool get isLoading => _loading;
  String? get errorCode => _errorCode;
  List<Category> get categories => _categories;
  List<Product> get products => _products;
  String? get selectedCategoryId => _selectedCategoryId;

  /// Charge les catégories puis les produits de la sélection courante.
  /// [categoryId] permet d'ouvrir directement sur une catégorie présélectionnée.
  Future<void> load({String? categoryId}) async {
    if (categoryId != null) _selectedCategoryId = categoryId;
    _loading = true;
    _errorCode = null;
    notifyListeners();
    try {
      _categories = await _repository.categories();
      _products = await _repository.products(categoryId: _selectedCategoryId);
    } on ApiException catch (e) {
      _errorCode = e.code;
    } catch (_) {
      _errorCode = ApiCodes.internalError;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Change la catégorie active (`null` = tous) et recharge les produits.
  Future<void> selectCategory(String? categoryId) async {
    if (categoryId == _selectedCategoryId) return;
    _selectedCategoryId = categoryId;
    _loading = true;
    _errorCode = null;
    notifyListeners();
    try {
      _products = await _repository.products(categoryId: categoryId);
    } on ApiException catch (e) {
      _errorCode = e.code;
    } catch (_) {
      _errorCode = ApiCodes.internalError;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
