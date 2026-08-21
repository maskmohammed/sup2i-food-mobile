import 'package:flutter/material.dart';

import '../../../app/settings_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Choix de la langue (FR / AR / EN) — applique la locale en direct (RTL inclus).
class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  static const List<(String, String)> _options = <(String, String)>[
    ('fr', 'Français'),
    ('ar', 'العربية'),
    ('en', 'English'),
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final settings = SettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.profileLanguage)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (code, name) in _options)
            _SelectTile(
              label: name,
              selected: settings.locale.languageCode == code,
              onTap: () => settings.setLocale(Locale(code)),
            ),
        ],
      ),
    );
  }
}

/// Choix du thème (Système / Clair / Sombre).
class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final settings = SettingsScope.of(context);
    final options = <(ThemeMode, String)>[
      (ThemeMode.system, loc.themeSystem),
      (ThemeMode.light, loc.themeLight),
      (ThemeMode.dark, loc.themeDark),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(loc.profileAppearance)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (mode, label) in options)
            _SelectTile(
              label: label,
              selected: settings.themeMode == mode,
              onTap: () => settings.setThemeMode(mode),
            ),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.pink600 : Theme.of(context).dividerColor,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(label),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? AppColors.pink600 : AppColors.muted,
        ),
      ),
    );
  }
}
