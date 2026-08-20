import 'package:flutter/material.dart';

import '../../../core/widgets/feature_placeholder.dart';
import '../../../l10n/app_localizations.dart';

/// Onglet Profil (compte étudiant, langue, préférences).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    return FeaturePlaceholder(
      title: loc.navProfile,
      icon: Icons.person_outline,
      message: loc.profileMessage,
    );
  }
}
