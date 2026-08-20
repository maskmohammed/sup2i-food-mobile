import 'package:flutter/foundation.dart';

import '../../../core/error/api_codes.dart';
import '../../../core/error/api_exception.dart';
import '../data/auth_repository.dart';
import '../domain/auth_session.dart';

/// État d'authentification de l'application.
///
/// Expose la session, l'état de chargement et le dernier `code` d'erreur.
/// Ne dépend d'aucune librairie de state management (M2 léger) :
/// simple [ChangeNotifier] partagé via `AuthScope`.
class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AuthSession? _session;
  bool _loading = false;
  String? _errorCode;

  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null;
  bool get isLoading => _loading;
  String? get errorCode => _errorCode;

  /// Tente la connexion. Retourne `true` si authentifié, sinon expose
  /// [errorCode]. Anti double-submit : ignore les appels concurrents.
  Future<bool> login(String email, String password) async {
    if (_loading) return false;
    _loading = true;
    _errorCode = null;
    notifyListeners();

    try {
      _session = await _repository.login(email: email, password: password);
      return true;
    } on ApiException catch (e) {
      _errorCode = e.code;
      return false;
    } catch (_) {
      _errorCode = ApiCodes.internalError;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _session = null;
    _errorCode = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorCode != null) {
      _errorCode = null;
      notifyListeners();
    }
  }
}
