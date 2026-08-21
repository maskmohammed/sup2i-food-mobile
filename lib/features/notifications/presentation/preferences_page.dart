import 'package:flutter/material.dart';

import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/preferences_controller.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

/// Préférences de notifications par catégorie (persistées serveur).
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
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
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
            padding: const EdgeInsets.all(16),
            children: [
              for (final category in NotificationCategory.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PrefCard(
                    title: loc.prefCategoryLabel(category),
                    description: loc.prefCategoryDesc(category),
                    value: _controller.isEnabled(category),
                    onChanged: (_) => _controller.toggle(category),
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
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
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
