import 'package:flutter/material.dart';

import '../../../app/settings_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../l10n/app_localizations.dart';

/// Language selection applied live through SettingsScope.
class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  static const List<(String, String)> _options = <(String, String)>[
    ('fr', 'Francais'),
    ('ar', 'العربية'),
    ('en', 'English'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = SettingsScope.of(context);

    return Scaffold(
      key: const Key('language_screen'),
      backgroundColor: context.surfaces.background,
      appBar: AppBar(title: Text(loc.profileLanguage)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: <Widget>[
          for (var index = 0; index < _options.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SettingsChoice(
                key: Key('language_option_$index'),
                icon: Icons.language_rounded,
                label: _options[index].$2,
                selected: settings.locale.languageCode == _options[index].$1,
                onTap: () => settings.setLocale(Locale(_options[index].$1)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Theme selection applied live through SettingsScope.
class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = SettingsScope.of(context);
    final options = <(ThemeMode, String, IconData)>[
      (ThemeMode.system, loc.themeSystem, Icons.brightness_auto_rounded),
      (ThemeMode.light, loc.themeLight, Icons.light_mode_outlined),
      (ThemeMode.dark, loc.themeDark, Icons.dark_mode_outlined),
    ];

    return Scaffold(
      key: const Key('appearance_screen'),
      backgroundColor: context.surfaces.background,
      appBar: AppBar(title: Text(loc.profileAppearance)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: <Widget>[
          for (var index = 0; index < options.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SettingsChoice(
                key: Key('appearance_option_$index'),
                icon: options[index].$3,
                label: options[index].$2,
                selected: settings.themeMode == options[index].$1,
                onTap: () => settings.setThemeMode(options[index].$1),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsChoice extends StatelessWidget {
  const _SettingsChoice({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.softPink : context.surfaces.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.pink600 : context.surfaces.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.pink600
                      : context.surfaces.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.neutral0 : AppColors.navy900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.navy900,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.pink600 : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
