import 'api_codes.dart';

/// Erreur métier renvoyée par la couche réseau/adaptateur.
///
/// Toujours porteuse d'un [code] du catalogue [ApiCodes] : l'UI décide du
/// message à afficher à partir de ce `code` (jamais du `message` serveur).
class ApiException implements Exception {
  const ApiException(this.code, {this.detail});

  /// Repli réseau/connexion (hors catalogue serveur).
  const ApiException.network({this.detail}) : code = ApiCodes.networkError;

  final String code;

  /// Détail technique non affiché à l'utilisateur (log/debug uniquement).
  final String? detail;

  @override
  String toString() => 'ApiException($code)';
}
