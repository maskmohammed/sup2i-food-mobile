import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../data/order_repository.dart';
import '../domain/order.dart';

/// État de l'historique des commandes.
class OrdersController extends ChangeNotifier {
  OrdersController(this._repository);

  final OrderRepository _repository;

  bool _loading = false;
  String? _errorCode;
  List<Order> _orders = const <Order>[];

  bool get isLoading => _loading;
  String? get errorCode => _errorCode;
  List<Order> get orders => _orders;

  Future<void> load() async {
    _loading = true;
    _errorCode = null;
    notifyListeners();
    try {
      _orders = await _repository.listOrders();
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
