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

enum _OrdersFilter { active, completed, cancelled }

/// Final student order history.
///
/// Statuses remain server-authoritative. Filters only change local
/// presentation of the repository result.
class OrdersListPage extends StatefulWidget {
  const OrdersListPage({super.key, this.repository});

  final OrderRepository? repository;

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  OrdersController? _controller;
  _OrdersFilter _filter = _OrdersFilter.active;

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

  List<Order> _filtered(List<Order> orders) {
    return orders.where((order) {
      switch (_filter) {
        case _OrdersFilter.active:
          return !_isCompleted(order.status) && !_isCancelled(order.status);
        case _OrdersFilter.completed:
          return _isCompleted(order.status);
        case _OrdersFilter.cancelled:
          return _isCancelled(order.status);
      }
    }).toList();
  }

  bool _isCompleted(OrderStatus status) {
    return status == OrderStatus.collected || status == OrderStatus.completed;
  }

  bool _isCancelled(OrderStatus status) {
    return status == OrderStatus.cancelled ||
        status == OrderStatus.expired ||
        status == OrderStatus.refunded ||
        status == OrderStatus.noShow;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('orders_screen'),
      backgroundColor: context.surfaces.background,
      body: SafeArea(
        child: ListenableBuilder(
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

            final filtered = _filtered(controller.orders);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _OrdersHeader(title: loc.navOrders, onRefresh: controller.load),
                const SizedBox(height: 16),
                _FilterBar(
                  selected: _filter,
                  onSelect: (value) {
                    setState(() => _filter = value);
                  },
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: filtered.isEmpty
                      ? _FilterEmpty(filter: _filter)
                      : RefreshIndicator(
                          color: AppColors.pink600,
                          onRefresh: controller.load,
                          child: ListView.separated(
                            key: const Key('orders_list'),
                            padding: const EdgeInsets.fromLTRB(20, 2, 20, 28),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) => _OrderCard(
                              order: filtered[index],
                              repository: widget.repository,
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.title, required this.onRefresh});

  final String title;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('orders_header'),
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 20),
      decoration: const BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x10161B5C),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.navy900,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Suivez vos commandes et retraits.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('orders_refresh'),
            onPressed: onRefresh,
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const AppBarActions(),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelect});

  final _OrdersFilter selected;
  final ValueChanged<_OrdersFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        key: const Key('orders_filters'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: <Widget>[
          _FilterPill(
            label: 'En cours',
            selected: selected == _OrdersFilter.active,
            onTap: () => onSelect(_OrdersFilter.active),
          ),
          const SizedBox(width: 9),
          _FilterPill(
            label: 'Terminées',
            selected: selected == _OrdersFilter.completed,
            onTap: () => onSelect(_OrdersFilter.completed),
          ),
          const SizedBox(width: 9),
          _FilterPill(
            label: 'Annulées',
            selected: selected == _OrdersFilter.cancelled,
            onTap: () => onSelect(_OrdersFilter.cancelled),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.pink600 : context.surfaces.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.pink600 : context.surfaces.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? AppColors.neutral0 : AppColors.navy900,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterEmpty extends StatelessWidget {
  const _FilterEmpty({required this.filter});

  final _OrdersFilter filter;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      _OrdersFilter.active => 'Aucune commande en cours',
      _OrdersFilter.completed => 'Aucune commande terminée',
      _OrdersFilter.cancelled => 'Aucune commande annulée',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.softPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.pink600,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
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
    final loc = AppLocalizations.of(context);
    final color = _statusColor(order.status);

    return Material(
      color: context.surfaces.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.receipt_long_rounded, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Commande #${order.number}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.navy900,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _date(order.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  _StatusChip(
                    label: loc.orderStatusLabel(order.status),
                    color: color,
                  ),
                  const Spacer(),
                  Text(
                    Money.format(order.totalCents),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.pink600,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 17,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${order.lines.length} article(s)',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  if (order.slotLabel != null) ...<Widget>[
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.schedule_rounded,
                      size: 17,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.slotLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _date(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color _statusColor(OrderStatus status) {
  if (status == OrderStatus.ready ||
      status == OrderStatus.paid ||
      status == OrderStatus.collected ||
      status == OrderStatus.completed) {
    return AppColors.success;
  }

  if (status == OrderStatus.cancelled ||
      status == OrderStatus.expired ||
      status == OrderStatus.noShow) {
    return AppColors.error;
  }

  if (status == OrderStatus.refunded) {
    return AppColors.warning;
  }

  if (status == OrderStatus.preparing || status == OrderStatus.queued) {
    return AppColors.pink600;
  }

  return AppColors.info;
}
