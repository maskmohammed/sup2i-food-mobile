import 'package:flutter/material.dart';

import '../../../app/app_bar_actions.dart';
import '../../../app/orders_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/format/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/orders_controller.dart';
import '../data/order_repository.dart';
import '../domain/order.dart';
import 'order_tracking_page.dart';

/// Onglet Commandes : historique. Statut par **badge + libellé texte** (jamais
/// signalé par la couleur seule).
class OrdersListPage extends StatefulWidget {
  const OrdersListPage({super.key, this.repository});

  final OrderRepository? repository;

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  OrdersController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final repo = widget.repository ?? OrdersScope.of(context);
      _controller = OrdersController(repo)..load();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.navOrders),
        actions: const [AppBarActions()],
      ),
      body: ListenableBuilder(
        listenable: _controller!,
        builder: (context, _) {
          final controller = _controller!;
          if (controller.isLoading && controller.orders.isEmpty) {
            return const AppLoadingView();
          }
          if (controller.errorCode != null && controller.orders.isEmpty) {
            return AppStateView.error(
              title: loc.errorMessage(
                controller.errorCode ?? ApiCodes.internalError,
              ),
              message: '',
              actionLabel: loc.retry,
              onAction: controller.load,
            );
          }
          if (controller.orders.isEmpty) {
            return AppStateView.empty(
              icon: Icons.receipt_long_outlined,
              title: loc.ordersEmpty,
              message: '',
            );
          }
          return RefreshIndicator(
            onRefresh: controller.load,
            color: AppColors.pink600,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _OrderCard(
                order: controller.orders[index],
                repository: widget.repository,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, this.repository});

  final Order order;
  final OrderRepository? repository;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: context.surfaces.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.surfaces.border),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                OrderTrackingPage(orderId: order.id, repository: repository),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Commande #${order.number}', style: text.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      _date(order.createdAt),
                      style: text.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 8),
                    _StatusChip(status: order.status, loc: loc),
                  ],
                ),
              ),
              Text(
                Money.format(order.totalCents),
                style: text.labelLarge?.copyWith(color: context.surfaces.text),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  String _date(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.loc});

  final OrderStatus status;
  final AppLocalizations loc;

  Color get _color => switch (status) {
    OrderStatus.ready ||
    OrderStatus.paid ||
    OrderStatus.collected ||
    OrderStatus.completed => AppColors.success,
    OrderStatus.cancelled ||
    OrderStatus.expired ||
    OrderStatus.noShow => AppColors.error,
    OrderStatus.refunded => AppColors.warning,
    _ => AppColors.info,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        loc.orderStatusLabel(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: _color),
      ),
    );
  }
}
