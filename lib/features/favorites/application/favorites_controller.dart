import 'package:flutter/foundation.dart' show ChangeNotifier;

/// Favoris (app-level). Client-side pour l'instant : à synchroniser avec le
/// serveur quand l'API favoris sera disponible (jalon M10 « si API prête »).
class FavoritesController extends ChangeNotifier {
  final Set<String> _ids = <String>{};

  Set<String> get ids => Set<String>.unmodifiable(_ids);
  bool isFavorite(String productId) => _ids.contains(productId);

  void toggle(String productId) {
    if (!_ids.add(productId)) _ids.remove(productId);
    notifyListeners();
  }
}
