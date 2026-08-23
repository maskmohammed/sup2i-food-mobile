import 'package:shared_preferences/shared_preferences.dart';

/// Persistance locale des recherches récentes (5 max, plus récente en tête).
///
/// Abstraction pour rester testable (fake en mémoire) et découplée du plugin.
/// Aucune donnée sensible ; purement local (pas de backend).
abstract interface class SearchHistoryStore {
  Future<List<String>> load();
  Future<void> save(List<String> terms);
}

/// Implémentation basée sur `shared_preferences`.
class SharedPreferencesSearchHistoryStore implements SearchHistoryStore {
  SharedPreferencesSearchHistoryStore([this._prefs]);

  SharedPreferences? _prefs;

  static const String _key = 'search.history';

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<List<String>> load() async {
    final prefs = await _instance;
    return prefs.getStringList(_key) ?? const <String>[];
  }

  @override
  Future<void> save(List<String> terms) async {
    final prefs = await _instance;
    await prefs.setStringList(_key, terms);
  }
}

/// Applique les règles d'historique : dédoublonnage (insensible à la casse),
/// terme le plus récent en tête, longueur plafonnée à [max].
List<String> mergeRecentSearch(
  List<String> current,
  String term, {
  int max = 5,
}) {
  final trimmed = term.trim();
  if (trimmed.isEmpty) return current;
  final result = <String>[
    trimmed,
    ...current.where((t) => t.toLowerCase() != trimmed.toLowerCase()),
  ];
  return result.length > max ? result.sublist(0, max) : result;
}
