import 'package:flutter/material.dart';

import '../features/auth/presentation/login_page.dart';
import '../l10n/app_localizations.dart';
import 'auth_scope.dart';

/// Garde d'authentification centralisée (mode invité + mur contextuel).
///
/// Point unique de la règle « connexion requise » : les écrans/onglets appellent
/// [AuthGuard.require] plutôt que de dupliquer la vérification. S'appuie sur
/// l'état d'auth réel ([AuthController] via `AuthScope`), jamais un booléen ad
/// hoc. Voir docs/design/decisions.md (D12).
abstract final class AuthGuard {
  static bool isAuthenticated(BuildContext context) =>
      AuthScope.of(context, listen: false).isAuthenticated;

  /// Retourne `true` si l'utilisateur est connecté. Sinon affiche le **mur de
  /// connexion** (modale centrée) et retourne `false` — l'appelant doit alors
  /// s'abstenir de l'action/navigation.
  static bool require(BuildContext context, {required String message}) {
    if (isAuthenticated(context)) return true;
    showLoginWall(context, message: message);
    return false;
  }
}

/// Mur de connexion contextuel : **modale centrée** (composants du design system
/// via `AppTheme` — `AlertDialog` Material 3). Fermable sans se connecter
/// (bouton secondaire ou tap en dehors) pour revenir à l'état précédent.
Future<void> showLoginWall(BuildContext context, {required String message}) {
  final AppLocalizations loc = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // tap en dehors = fermer sans se connecter
    builder: (dialogContext) => AlertDialog(
      title: Text(loc.loginWallTitle),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(loc.loginWallLater),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(); // ferme la modale
            Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const LoginPage()));
          },
          child: Text(loc.loginWallSignIn),
        ),
      ],
    ),
  );
}
