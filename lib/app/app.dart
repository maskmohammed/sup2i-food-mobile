import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/login_page.dart';
import '../l10n/app_localizations.dart';

/// Racine de l'application SUP2I FOOD.
class Sup2iFoodApp extends StatelessWidget {
  const Sup2iFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // FR par défaut (app FR-first) ; le sélecteur de langue (écran Langue,
      // M2) changera cette locale. Migration vers flutter_localizations + .arb
      // prévue en M2.
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Applique la direction (RTL pour l'arabe) tant que les delegates globaux
      // de flutter_localizations ne sont pas branchés.
      builder: (context, child) => Directionality(
        textDirection: AppLocalizations.of(context).textDirection,
        child: child!,
      ),
      home: const LoginPage(),
    );
  }
}
