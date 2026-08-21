import 'package:flutter_test/flutter_test.dart';

import 'package:sup2i_food_mobile/features/canteen/application/canteen_controller.dart';
import 'package:sup2i_food_mobile/features/canteen/data/canteen_repository.dart';
import 'package:sup2i_food_mobile/features/canteen/domain/canteen.dart';

CanteenController controller() =>
    CanteenController(const MockCanteenRepository(latency: Duration.zero));

void main() {
  test('loadMenu : 5 plats', () async {
    final c = controller();
    await c.loadMenu();
    expect(c.menu.length, 5);
    expect(c.errorCode, isNull);
  });

  test('loadSubscription : quota 8/12, actif', () async {
    final c = controller();
    await c.loadSubscription();
    expect(c.subscription, isNotNull);
    expect(c.subscription!.quotaRemaining, 8);
    expect(c.subscription!.active, isTrue);
  });

  test('loadFoodPass : actif', () async {
    final c = controller();
    await c.loadFoodPass();
    expect(c.foodPass, isNotNull);
    expect(c.foodPass!.status, FoodPassStatus.active);
    expect(c.foodPass!.studentName, 'Chnaf Yahya');
  });
}
