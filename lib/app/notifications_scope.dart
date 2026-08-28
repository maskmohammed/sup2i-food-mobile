import 'package:flutter/widgets.dart';

import '../features/notifications/application/notifications_controller.dart';

/// Fournit le [NotificationsController] à toute l'app (badge cloche réactif +
/// écran Centre de notifications).
class NotificationsScope extends InheritedNotifier<NotificationsController> {
  const NotificationsScope({
    super.key,
    required NotificationsController controller,
    required super.child,
  }) : super(notifier: controller);

  static NotificationsController of(
    BuildContext context, {
    bool listen = true,
  }) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<NotificationsScope>()
        : context.getInheritedWidgetOfExactType<NotificationsScope>();
    assert(scope != null, 'NotificationsScope introuvable dans l\'arbre.');
    return scope!.notifier!;
  }
}
