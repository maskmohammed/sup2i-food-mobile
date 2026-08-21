import 'package:flutter/material.dart';

import '../../../core/widgets/feature_placeholder.dart';
import '../../../l10n/app_localizations.dart';

/// Onglet Commander (catalogue Snack + panier).
class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    return FeaturePlaceholder(
      title: loc.navOrder,
      icon: Icons.shopping_bag_outlined,
      message: loc.orderMessage,
    );
  }
}
