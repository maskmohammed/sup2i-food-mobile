import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../app/auth_scope.dart';
import '../../../app/cart_scope.dart';
import '../../../app/favorites_scope.dart';
import '../../../app/orders_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../l10n/app_localizations.dart';
import '../../canteen/presentation/food_pass_page.dart';
import '../../canteen/presentation/subscription_page.dart';
import '../../favorites/presentation/favorites_page.dart';
import '../../notifications/presentation/notifications_page.dart';
import '../../notifications/presentation/preferences_page.dart';
import '../../orders/data/mock_order_repository.dart';
import '../../rewards/presentation/rewards_pages.dart';
import '../../settings/presentation/settings_pages.dart';

/// Final student profile hub.
///
/// Identity is session-driven. Logout remains owned by AuthScope.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _confirmLogout(
    BuildContext context,
    AppLocalizations loc,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        title: Text(loc.profileLogout),
        content: const Text(
          'Vous devrez vous reconnecter pour acceder a SUP2I FOOD.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('profile_logout_confirm'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(loc.profileLogout),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    AuthScope.of(context, listen: false).logout();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final session = AuthScope.of(context, listen: false).session;

    void comingSoon() {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.comingSoon)));
    }

    void resetMockData() {
      CartScope.of(context, listen: false).clear();
      FavoritesScope.of(context, listen: false).clear();

      final repo = OrdersScope.of(context);
      if (repo is MockOrderRepository) {
        repo.reset();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.devMockDataReset)));
    }

    return Scaffold(
      key: const Key('profile_screen'),
      backgroundColor: context.surfaces.background,
      body: SafeArea(
        child: ListView(
          key: const Key('profile_scroll'),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: <Widget>[
            _ProfileHero(
              name: session?.displayName ?? '',
              studentId: session?.studentId ?? '',
              idLabel: loc.profileIdLabel,
            ),
            const SizedBox(height: 22),
            _SectionTitle(title: 'Mon espace'),
            const SizedBox(height: 10),
            _SettingsGroup(
              children: <Widget>[
                _ProfileRow(
                  key: const Key('profile_food_pass'),
                  icon: Icons.qr_code_2_rounded,
                  label: loc.foodPassButton,
                  onTap: () => _push(context, const FoodPassPage()),
                ),
                _ProfileRow(
                  key: const Key('profile_subscription'),
                  icon: Icons.card_membership_rounded,
                  label: loc.subscriptionButton,
                  onTap: () => _push(context, const SubscriptionPage()),
                ),
                _ProfileRow(
                  icon: Icons.favorite_border_rounded,
                  label: loc.profileFavorites,
                  onTap: () => _push(context, const FavoritesPage()),
                ),
                _ProfileRow(
                  icon: Icons.local_offer_outlined,
                  label: loc.profilePromotions,
                  onTap: () => _push(context, const PromotionsPage()),
                ),
                _ProfileRow(
                  icon: Icons.workspace_premium_outlined,
                  label: loc.profileLoyalty,
                  onTap: () => _push(context, const LoyaltyPage()),
                  last: true,
                ),
              ],
            ),
            const SizedBox(height: 22),
            _SectionTitle(title: 'Notifications'),
            const SizedBox(height: 10),
            _SettingsGroup(
              children: <Widget>[
                _ProfileRow(
                  key: const Key('profile_notifications'),
                  icon: Icons.notifications_none_rounded,
                  label: loc.profileNotifications,
                  onTap: () => _push(context, const NotificationsPage()),
                ),
                _ProfileRow(
                  key: const Key('profile_preferences'),
                  icon: Icons.tune_rounded,
                  label: loc.profilePreferences,
                  onTap: () => _push(context, const PreferencesPage()),
                  last: true,
                ),
              ],
            ),
            const SizedBox(height: 22),
            _SectionTitle(title: 'Application'),
            const SizedBox(height: 10),
            _SettingsGroup(
              children: <Widget>[
                _ProfileRow(
                  key: const Key('profile_language'),
                  icon: Icons.language_rounded,
                  label: loc.profileLanguage,
                  onTap: () => _push(context, const LanguagePage()),
                ),
                _ProfileRow(
                  key: const Key('profile_appearance'),
                  icon: Icons.brightness_6_rounded,
                  label: loc.profileAppearance,
                  onTap: () => _push(context, const AppearancePage()),
                ),
                _ProfileRow(
                  icon: Icons.help_outline_rounded,
                  label: loc.profileHelp,
                  onTap: comingSoon,
                  last: true,
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                key: const Key('profile_logout'),
                onPressed: () => _confirmLogout(context, loc),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: Text(loc.profileLogout),
              ),
            ),
            if (kDebugMode) ...<Widget>[
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: TextButton.icon(
                  onPressed: resetMockData,
                  icon: const Icon(
                    Icons.restart_alt_rounded,
                    color: AppColors.muted,
                  ),
                  label: Text(
                    loc.devResetMockData,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.studentId,
    required this.idLabel,
  });

  final String name;
  final String studentId;
  final String idLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('profile_hero'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.navy900, AppColors.blue600],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.neutral0,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.pink600,
              size: 36,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name.isEmpty ? 'Etudiant SUP2I' : name,
                  key: const Key('profile_name'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.neutral0,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$idLabel : $studentId',
                  key: const Key('profile_student_id'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral0.withValues(alpha: 0.76),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(color: AppColors.navy900, fontSize: 17),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaces.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.surfaces.border),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.softPink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.pink600, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.navy900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
        if (!last)
          Padding(
            padding: const EdgeInsets.only(left: 66),
            child: Divider(height: 1, color: context.surfaces.border),
          ),
      ],
    );
  }
}
