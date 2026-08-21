import 'package:flutter/material.dart';

import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/notifications_controller.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

/// Centre de notifications. Le contenu/état vient du serveur (push M9) ; le type
/// est lisible sans la couleur seule (titre texte explicite).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, this.repository});

  final NotificationsRepository? repository;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController(
      widget.repository ?? MockNotificationsRepository(),
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.notificationsTitle)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.items.isEmpty) {
            return const AppLoadingView();
          }
          if (_controller.errorCode != null && _controller.items.isEmpty) {
            return AppStateView.error(
              title: loc.errorMessage(
                _controller.errorCode ?? ApiCodes.internalError,
              ),
              message: '',
              actionLabel: loc.retry,
              onAction: _controller.load,
            );
          }
          if (_controller.items.isEmpty) {
            return AppStateView.empty(
              icon: Icons.notifications_none,
              title: loc.notificationsEmpty,
              message: '',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _NotificationCard(item: _controller.items[index]),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final AppNotification item;

  Color get _dotColor => switch (item.type) {
    NotificationType.orderReady => AppColors.success,
    NotificationType.paymentConfirmed => AppColors.info,
    NotificationType.quotaLow => AppColors.warning,
    NotificationType.reservationConfirmed => AppColors.blue600,
    NotificationType.generic => AppColors.muted,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.read
            ? context.surfaces.surface
            : AppColors.pink500.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.surfaces.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: text.bodyMedium?.copyWith(
                    fontWeight: item.read ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.timeLabel,
            style: text.labelSmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
