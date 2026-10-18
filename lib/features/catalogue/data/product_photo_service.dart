import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fournit une URL de photo pour un produit (recherche par mot-clé).
abstract interface class ProductPhotoService {
  /// Retourne une URL d'image pour [query], ou `null` si indisponible
  /// (service désactivé, hors-ligne, erreur, aucun résultat).
  Future<String?> photoUrl(String query);
}

/// ⚠️⚠️⚠️ PHOTOS DE DÉVELOPPEMENT UNIQUEMENT — NE PAS UTILISER EN PRODUCTION.
///
/// Ce service récupère des photos génériques de nourriture via l'API officielle
/// Unsplash pour remplacer les placeholders PENDANT LE DÉVELOPPEMENT. Ces images
/// ne correspondent PAS aux produits réellement servis par SUP2I FOOD : les
/// afficher en production induirait le client en erreur (photo ≠ plat servi).
/// Elles doivent être remplacées par les vraies photos produits avant toute
/// mise en production. Voir docs/design/decisions.md (D9).
///
/// La clé API est lue depuis l'ENVIRONNEMENT (jamais en dur) :
///   flutter run --dart-define=UNSPLASH_ACCESS_KEY=xxxxx
/// Sans clé, le service est **désactivé** et retourne toujours `null`
/// (placeholder conservé), ce qui garde les tests/CI hors-ligne verts.
class UnsplashPhotoService implements ProductPhotoService {
  UnsplashPhotoService({http.Client? client, String? accessKey})
    : _client = client ?? http.Client(),
      _accessKey =
          accessKey ?? const String.fromEnvironment('UNSPLASH_ACCESS_KEY');

  final http.Client _client;
  final String _accessKey;

  /// Cache mémoire par requête (évite les appels répétés en dev).
  final Map<String, String?> _cache = <String, String?>{};

  bool get isEnabled => _accessKey.isNotEmpty;

  @override
  Future<String?> photoUrl(String query) async {
    if (!isEnabled) return null;
    if (_cache.containsKey(query)) return _cache[query];

    try {
      final uri = Uri.https('api.unsplash.com', '/search/photos', {
        'query': query,
        'per_page': '1',
        'orientation': 'landscape',
        'content_filter': 'high',
        'client_id': _accessKey,
      });
      final res = await _client.get(uri);
      if (res.statusCode != 200) return _cache[query] = null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return _cache[query] = null;
      final urls =
          (results.first as Map<String, dynamic>)['urls']
              as Map<String, dynamic>?;
      return _cache[query] = urls?['small'] as String?;
    } on Object {
      // Hors-ligne / erreur réseau / parsing : on retombe sur le placeholder.
      return _cache[query] = null;
    }
  }
}

/// Instance par défaut (dev-only, désactivée sans clé d'environnement).
final ProductPhotoService defaultProductPhotoService = UnsplashPhotoService();
