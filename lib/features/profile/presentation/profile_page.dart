import 'package:flutter/material.dart';

import '../../../app/auth_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';

/// Onglet Profil (compte étudiant, langue, préférences).
/// M1 : placeholder. M2 : bouton de déconnexion réel.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.navProfile)),
      body: Column(
        children: [
          Expanded(
            child: AppStateView.empty(
              icon: Icons.person_outline,
              title: loc.navProfile,
              message: loc.profileMessage,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => AuthScope.of(context, listen: false).logout(),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  loc.profileLogout,
                  style: const TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
