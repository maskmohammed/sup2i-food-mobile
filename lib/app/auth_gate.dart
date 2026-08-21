import 'package:flutter/material.dart';

import '../features/auth/presentation/login_page.dart';
import 'app_shell.dart';
import 'auth_scope.dart';

/// Aiguille entre l'écran de connexion et l'app shell selon l'état d'auth.
/// Se reconstruit automatiquement à la connexion / déconnexion.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return auth.isAuthenticated ? const AppShell() : const LoginPage();
  }
}
