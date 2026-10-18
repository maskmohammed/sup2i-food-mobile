import 'package:flutter/material.dart';

import '../../../../app/notifications_scope.dart';
import '../../../../core/widgets/badged_icon_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../notifications_page.dart';

/// Icône cloche avec badge du nombre de notifications non lues (composant
/// partagé [BadgedIconButton]). Réactif via [NotificationsScope]. Au tap,
/// ouvre le Centre de notifications.
class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final count = NotificationsScope.of(context).unreadCount;

    return BadgedIconButton(
      icon: Icons.notifications_none,
      count: count,
      tooltip: loc.notificationsTooltip,
      semanticLabel: loc.notificationsUnreadA11y(count),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const NotificationsPage()),
      ),
    );
  }
}
