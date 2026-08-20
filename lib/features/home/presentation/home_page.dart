import 'package:flutter/material.dart';

import '../../../core/widgets/feature_placeholder.dart';
import '../../../l10n/app_localizations.dart';

/// Onglet Accueil.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    return FeaturePlaceholder(
      title: loc.navHome,
      icon: Icons.home_outlined,
      message: loc.homeMessage,
    );
  }
}
