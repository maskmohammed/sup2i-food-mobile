import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../data/order_repository.dart';
import '../domain/order.dart';

/// État du suivi d'une commande (chargement, annulation).
class OrderTrackingController extends ChangeNotifier {
  OrderTrackingController(this._repository);

  final OrderRepository _repository;

  bool _loading = false;
  String? _errorCode;
  Order? _order;

  bool get isLoading => _loading;
  String? get errorCode => _errorCode;
  Order? get order => _order;

  Future<void> load(String orderId) async {
    _loading = true;
    _errorCode = null;
    notifyListeners();
    try {
      _order = await _repository.getOrder(orderId);
    } on ApiException catch (e) {
      _errorCode = e.code;
    } catch (_) {
      _errorCode = ApiCodes.internalError;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Annule la commande. Retourne le `code` d'erreur si refusé, sinon `null`.
  Future<String?> cancel() async {
    final order = _order;
    if (order == null) return ApiCodes.internalError;
    try {
      _order = await _repository.cancelOrder(order.id);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.code;
    } catch (_) {
      return ApiCodes.internalError;
    }
  }
}
