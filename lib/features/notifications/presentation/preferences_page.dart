import 'package:flutter/material.dart';

import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/preferences_controller.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

/// Server-persisted notification preferences.
class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key, this.repository});

  final NotificationsRepository? repository;

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late final PreferencesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PreferencesController(
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
      key: const Key('preferences_screen'),
      backgroundColor: context.surfaces.background,
      appBar: AppBar(title: Text(loc.preferencesTitle)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.prefs.isEmpty) {
            return const AppLoadingView();
          }

          if (_controller.errorCode != null && _controller.prefs.isEmpty) {
            return AppStateView.error(
              title: loc.errorMessage(
                _controller.errorCode ?? ApiCodes.internalError,
              ),
              message: '',
              actionLabel: loc.retry,
              onAction: _controller.load,
            );
          }

          return ListView(
            key: const Key('preferences_list'),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.blue600,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Choisissez les notifications utiles. '
                        'Vos preferences sont enregistrees '
                        'par le service de notifications.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.navy900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (
                var index = 0;
                index < NotificationCategory.values.length;
                index++
              )
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PrefCard(
                    key: Key('notification_pref_$index'),
                    title: loc.prefCategoryLabel(
                      NotificationCategory.values[index],
                    ),
                    description: loc.prefCategoryDesc(
                      NotificationCategory.values[index],
                    ),
                    value: _controller.isEnabled(
                      NotificationCategory.values[index],
                    ),
                    onChanged: (_) =>
                        _controller.toggle(NotificationCategory.values[index]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PrefCard extends StatelessWidget {
  const _PrefCard({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaces.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value
              ? AppColors.pink600.withValues(alpha: 0.34)
              : context.surfaces.border,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: value ? AppColors.softPink : context.surfaces.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: value ? AppColors.pink600 : AppColors.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.navy900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.pink600,
          ),
        ],
      ),
    );
  }
}
