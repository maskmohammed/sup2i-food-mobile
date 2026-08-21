import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

/// Préférences de notifications (par catégorie).
class PreferencesController extends ChangeNotifier {
  PreferencesController(this._repository);

  final NotificationsRepository _repository;

  bool _loading = false;
  String? _errorCode;
  Map<NotificationCategory, bool> _prefs = const <NotificationCategory, bool>{};

  bool get isLoading => _loading;
  String? get errorCode => _errorCode;
  Map<NotificationCategory, bool> get prefs => _prefs;

  bool isEnabled(NotificationCategory category) => _prefs[category] ?? false;

  Future<void> load() async {
    _loading = true;
    _errorCode = null;
    notifyListeners();
    try {
      _prefs = await _repository.preferences();
    } on ApiException catch (e) {
      _errorCode = e.code;
    } catch (_) {
      _errorCode = ApiCodes.internalError;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Bascule optimiste ; rollback si l'appel serveur échoue.
  Future<void> toggle(NotificationCategory category) async {
    final previous = isEnabled(category);
    _prefs = <NotificationCategory, bool>{..._prefs, category: !previous};
    notifyListeners();
    try {
      await _repository.setPreference(category, !previous);
    } catch (_) {
      _prefs = <NotificationCategory, bool>{..._prefs, category: previous};
      notifyListeners();
    }
  }
}
