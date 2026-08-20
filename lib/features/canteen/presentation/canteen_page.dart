import 'package:flutter/material.dart';

import '../../../core/widgets/feature_placeholder.dart';
import '../../../l10n/app_localizations.dart';

/// Onglet Cantine (abonnement, Food Pass).
class CanteenPage extends StatelessWidget {
  const CanteenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    return FeaturePlaceholder(
      title: loc.navCanteen,
      icon: Icons.restaurant_outlined,
      message: loc.canteenMessage,
    );
  }
}
