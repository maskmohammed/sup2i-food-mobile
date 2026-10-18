import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

/// Liste des notifications.
class NotificationsController extends ChangeNotifier {
  NotificationsController(this._repository);

  final NotificationsRepository _repository;

  bool _loading = false;
  String? _errorCode;
  List<AppNotification> _items = const <AppNotification>[];

  bool get isLoading => _loading;
  String? get errorCode => _errorCode;
  List<AppNotification> get items => _items;

  /// Nombre de notifications non lues (dérivé, jamais codé en dur) — alimente
  /// le badge de la cloche.
  int get unreadCount => _items.where((n) => !n.read).length;

  Future<void> load() async {
    _loading = true;
    _errorCode = null;
    notifyListeners();
    try {
      _items = await _repository.list();
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
