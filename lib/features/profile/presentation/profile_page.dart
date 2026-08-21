import 'package:flutter/material.dart';

import '../../../app/auth_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../canteen/presentation/food_pass_page.dart';
import '../../canteen/presentation/subscription_page.dart';
import '../../notifications/presentation/notifications_page.dart';
import '../../notifications/presentation/preferences_page.dart';

/// Onglet Profil : identité, accès (notifications, préférences, Food Pass,
/// abonnement, langue, aide) et déconnexion.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final session = AuthScope.of(context, listen: false).session;

    void comingSoon() => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.comingSoon)));

    return Scaffold(
      appBar: AppBar(title: Text(loc.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Identity(
            name: session?.displayName ?? '',
            id: session?.studentId ?? '',
            idLabel: loc.profileIdLabel,
          ),
          const SizedBox(height: 16),
          _Row(
            icon: Icons.notifications_none,
            label: loc.profileNotifications,
            onTap: () => _push(context, const NotificationsPage()),
          ),
          _Row(
            icon: Icons.tune,
            label: loc.profilePreferences,
            onTap: () => _push(context, const PreferencesPage()),
          ),
          _Row(
            icon: Icons.card_membership,
            label: loc.subscriptionButton,
            onTap: () => _push(context, const SubscriptionPage()),
          ),
          _Row(
            icon: Icons.qr_code_2,
            label: loc.foodPassButton,
            onTap: () => _push(context, const FoodPassPage()),
          ),
          _Row(
            icon: Icons.language,
            label: loc.profileLanguage,
            onTap: comingSoon,
          ),
          _Row(
            icon: Icons.help_outline,
            label: loc.profileHelp,
            onTap: comingSoon,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
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
        ],
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({
    required this.name,
    required this.id,
    required this.idLabel,
  });

  final String name;
  final String id;
  final String idLabel;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.neutral100,
          child: Icon(Icons.person, color: AppColors.muted, size: 30),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: text.titleLarge),
            Text(
              '$idLabel : $id',
              style: text.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.neutral0,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.navy900),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      ),
    );
  }
}
