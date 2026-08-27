import 'package:flutter/material.dart';

import '../features/cart/presentation/widgets/cart_button.dart';
import '../features/notifications/presentation/widgets/notification_button.dart';

/// Actions d'en-tête partagées des écrans principaux : cloche notifications +
/// panier (même composant badge). À placer dans `AppBar.actions`.
class AppBarActions extends StatelessWidget {
  const AppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [NotificationButton(), CartButton()],
    );
  }
}
