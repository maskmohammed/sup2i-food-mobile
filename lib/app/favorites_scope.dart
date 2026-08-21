import 'package:flutter/widgets.dart';

import '../features/favorites/application/favorites_controller.dart';

/// Fournit le [FavoritesController] à l'app (cœurs des cartes, écran Favoris).
class FavoritesScope extends InheritedNotifier<FavoritesController> {
  const FavoritesScope({
    super.key,
    required FavoritesController controller,
    required super.child,
  }) : super(notifier: controller);

  static FavoritesController of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<FavoritesScope>()
        : context.getInheritedWidgetOfExactType<FavoritesScope>();
    assert(scope != null, 'FavoritesScope introuvable dans l\'arbre.');
    return scope!.notifier!;
  }
}
