import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/features/notifications/application/notifications_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/application/preferences_controller.dart';
import 'package:sup2i_food_mobile/features/notifications/data/notifications_repository.dart';
import 'package:sup2i_food_mobile/features/notifications/domain/app_notification.dart';

void main() {
  test('NotificationsController.load : 4 notifications', () async {
    final c = NotificationsController(
      MockNotificationsRepository(latency: Duration.zero),
    );
    await c.load();
    expect(c.items.length, 4);
    expect(c.errorCode, isNull);
  });

  test('PreferencesController : chargement + bascule', () async {
    final c = PreferencesController(
      MockNotificationsRepository(latency: Duration.zero),
    );
    await c.load();
    expect(c.isEnabled(NotificationCategory.transactional), isTrue);
    expect(c.isEnabled(NotificationCategory.promotions), isFalse);

    await c.toggle(NotificationCategory.promotions);
    expect(c.isEnabled(NotificationCategory.promotions), isTrue);
  });
}
