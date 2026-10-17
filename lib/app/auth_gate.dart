import 'package:flutter/material.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/splash_page.dart';
import 'app_shell.dart';
import 'auth_scope.dart';

/// Final entry flow for SUP2I FOOD:
/// animated splash -> mandatory login -> authenticated application shell.
///
/// There is intentionally no guest mode and no registration path.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _splashCompleted = false;

  void _finishSplash() {
    if (!mounted) return;
    setState(() => _splashCompleted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashCompleted) {
      return SplashPage(onFinished: _finishSplash);
    }

    final auth = AuthScope.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: auth.isAuthenticated
          ? const AppShell(key: ValueKey('authenticated_shell'))
          : const LoginPage(key: ValueKey('mandatory_login')),
    );
  }
}
