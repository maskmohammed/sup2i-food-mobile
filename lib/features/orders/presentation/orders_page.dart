import 'package:flutter/material.dart';

import '../../../core/widgets/feature_placeholder.dart';
import '../../../l10n/app_localizations.dart';

/// Onglet Commandes (historique et suivi temps réel).
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    return FeaturePlaceholder(
      title: loc.navOrders,
      icon: Icons.receipt_long_outlined,
      message: loc.ordersMessage,
    );
  }
}
