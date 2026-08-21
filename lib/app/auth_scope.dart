import 'package:flutter/widgets.dart';

import '../features/auth/application/auth_controller.dart';

/// Fournit l'[AuthController] à l'arbre de widgets et rebâtit ses dépendants
/// (ex. `AuthGate`) à chaque changement d'état d'authentification.
class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Accès au contrôleur. `listen: false` pour appeler des méthodes sans
  /// s'abonner aux reconstructions (ex. depuis un handler de bouton).
  static AuthController of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<AuthScope>()
        : context.getInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope introuvable dans l\'arbre de widgets.');
    return scope!.notifier!;
  }
}
