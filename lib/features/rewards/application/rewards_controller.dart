import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../data/rewards_repository.dart';
import '../domain/rewards.dart';

/// État promotions + fidélité (chargés à la demande selon l'écran).
class RewardsController extends ChangeNotifier {
  RewardsController(this._repository);

  final RewardsRepository _repository;

  bool _loading = false;
  String? _errorCode;
  List<Promotion> _promotions = const <Promotion>[];
  LoyaltyBalance? _loyalty;
  List<LoyaltyEntry> _history = const <LoyaltyEntry>[];

  bool get isLoading => _loading;
  String? get errorCode => _errorCode;
  List<Promotion> get promotions => _promotions;
  LoyaltyBalance? get loyalty => _loyalty;
  List<LoyaltyEntry> get history => _history;

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

  Future<void> loadPromotions() =>
      _run(() async => _promotions = await _repository.promotions());

  Future<void> loadLoyalty() => _run(() async {
    _loyalty = await _repository.loyalty();
    _history = await _repository.loyaltyHistory();
  });
}
