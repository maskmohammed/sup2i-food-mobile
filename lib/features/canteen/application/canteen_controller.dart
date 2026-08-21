import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../data/canteen_repository.dart';
import '../domain/canteen.dart';

/// État cantine : menu de la semaine, abonnement, Food Pass (sections
/// chargées à la demande selon l'écran).
class CanteenController extends ChangeNotifier {
  CanteenController(this._repository);

  final CanteenRepository _repository;

  bool _loading = false;
  String? _errorCode;
  List<MealDay> _menu = const <MealDay>[];
  Subscription? _subscription;
  FoodPass? _foodPass;

  bool get isLoading => _loading;
  String? get errorCode => _errorCode;
  List<MealDay> get menu => _menu;
  Subscription? get subscription => _subscription;
  FoodPass? get foodPass => _foodPass;

  Future<void> _run(Future<void> Function() action) async {
    _loading = true;
    _errorCode = null;
    notifyListeners();
    try {
      await action();
    } on ApiException catch (e) {
      _errorCode = e.code;
    } catch (_) {
      _errorCode = ApiCodes.internalError;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMenu() =>
      _run(() async => _menu = await _repository.weeklyMenu());

  Future<void> loadSubscription() =>
      _run(() async => _subscription = await _repository.subscription());

  Future<void> loadFoodPass() =>
      _run(() async => _foodPass = await _repository.foodPass());
}
