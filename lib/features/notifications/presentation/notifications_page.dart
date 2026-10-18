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

/// Final notification center.
///
/// Content, read state and notification type remain repository/server data.
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
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('notifications_screen'),
      backgroundColor: context.surfaces.background,
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
              icon: Icons.notifications_none_rounded,
              title: loc.notificationsEmpty,
              message: '',
            );
          }

          return RefreshIndicator(
            color: AppColors.pink600,
            onRefresh: _controller.load,
            child: ListView.separated(
              key: const Key('notifications_list'),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _controller.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _NotificationCard(
                key: Key('notification_card_$index'),
                item: _controller.items[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({super.key, required this.item});

  final AppNotification item;

  Color get _accentColor {
    switch (item.type) {
      case NotificationType.orderReady:
        return AppColors.success;
      case NotificationType.paymentConfirmed:
        return AppColors.info;
      case NotificationType.quotaLow:
        return AppColors.warning;
      case NotificationType.reservationConfirmed:
        return AppColors.blue600;
      case NotificationType.generic:
        return AppColors.muted;
    }
  }

  IconData get _icon {
    switch (item.type) {
      case NotificationType.orderReady:
        return Icons.check_circle_outline_rounded;
      case NotificationType.paymentConfirmed:
        return Icons.payments_outlined;
      case NotificationType.quotaLow:
        return Icons.warning_amber_rounded;
      case NotificationType.reservationConfirmed:
        return Icons.restaurant_outlined;
      case NotificationType.generic:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.read ? context.surfaces.surface : AppColors.softPink,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.read
              ? context.surfaces.border
              : AppColors.pink600.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.navy900,
                          fontWeight: item.read
                              ? FontWeight.w600
                              : FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.timeLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                if (!item.read) ...<Widget>[
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.pink600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Nouveau',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.pink600,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
