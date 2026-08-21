import 'package:flutter/widgets.dart';

import '../features/settings/application/settings_controller.dart';

/// Fournit le [SettingsController] (langue + thème) à toute l'app.
class SettingsScope extends InheritedNotifier<SettingsController> {
  const SettingsScope({
    super.key,
    required SettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static SettingsController of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<SettingsScope>()
        : context.getInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'SettingsScope introuvable dans l\'arbre.');
    return scope!.notifier!;
  }
}
