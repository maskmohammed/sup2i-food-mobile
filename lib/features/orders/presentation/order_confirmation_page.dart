import 'package:flutter/material.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/brand_chef_mascot.dart';
import '../domain/order.dart';
import 'order_tracking_page.dart';

/// Success hand-off shown after the server has created the order.
///
/// It does not claim payment success. The order status shown afterward remains
/// server-authoritative through OrderTrackingPage.
class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key, required this.order});

  final Order order;

  void _track(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => OrderTrackingPage(orderId: order.id),
      ),
    );
  }

  void _home(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('order_confirmation_screen'),
      backgroundColor: context.surfaces.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(
            children: <Widget>[
              const Spacer(),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 152,
                    height: 152,
                    decoration: const BoxDecoration(
                      color: AppColors.softPink,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Positioned(
                    right: -2,
                    bottom: -4,
                    child: BrandChefMascot(width: 105, height: 122),
                  ),
                  Positioned(
                    left: 15,
                    top: 15,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: AppColors.pink600,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.neutral0,
                        size: 34,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              Text(
                'Commande confirmee !',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 27),
              ),
              const SizedBox(height: 9),
              Text(
                'Votre commande a bien ete creee. '
                'Suivez son statut depuis l application.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: context.surfaces.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.surfaces.border),
                ),
                child: Column(
                  children: <Widget>[
                    _SummaryRow(label: 'Commande', value: '#${order.number}'),
                    if (order.slotLabel != null) ...<Widget>[
                      const SizedBox(height: 10),
                      _SummaryRow(label: 'Retrait', value: order.slotLabel!),
                    ],
                    const SizedBox(height: 10),
                    _SummaryRow(
                      label: 'Total serveur',
                      value: Money.format(order.totalCents),
                      emphasized: true,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  key: const Key('confirmation_track'),
                  onPressed: () => _track(context),
                  icon: const Icon(Icons.route_rounded),
                  label: const Text('Suivre ma commande'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  key: const Key('confirmation_home'),
                  onPressed: () => _home(context),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Retour a l accueil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: emphasized ? AppColors.pink600 : AppColors.navy900,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
