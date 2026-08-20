import '../domain/auth_session.dart';

/// Contrat d'accès à l'authentification.
///
/// Implémentation actuelle : [MockAuthRepository] (aucun backend/OpenAPI
/// disponible). Une implémentation HTTP réelle la remplacera sans toucher à
/// l'UI ni au contrôleur, une fois le contrat serveur confirmé.
abstract interface class AuthRepository {
  /// Authentifie l'étudiant. Lève [ApiException] (avec un `code`) en cas d'échec.
  Future<AuthSession> login({required String email, required String password});

  /// Termine la session locale.
  Future<void> logout();
}
