import 'package:flutter/material.dart';

import 'app_shell.dart';

/// Entrée de l'application en **mode invité** : l'app est librement accessible
/// (Accueil + catalogue) sans connexion. L'authentification est exigée de façon
/// **contextuelle** (onglets Cantine/Commandes/Profil, ajout au panier /
/// commande) via `AuthGuard` et son mur de connexion. Voir D12.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) => const AppShell();
}
