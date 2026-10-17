import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/orders_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/format/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/order_tracking_controller.dart';
import '../data/order_repository.dart';
import '../domain/order.dart';
import 'order_ready_page.dart';

/// Final server-authoritative order tracking.
class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key, required this.orderId, this.repository});

  final String orderId;
  final OrderRepository? repository;

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  OrderTrackingController? _controller;
  OrderStatus? _lastStatus;
  bool _firstEmission = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_controller == null) {
      final repo = widget.repository ?? OrdersScope.of(context);

      _controller = OrderTrackingController(repo)
        ..addListener(_onControllerChanged)
        ..load(widget.orderId);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final order = _controller?.order;
    if (order == null) return;

    final previous = _lastStatus;
    _lastStatus = order.status;

    if (_firstEmission) {
      _firstEmission = false;
      return;
    }

    if (order.status == OrderStatus.ready && previous != OrderStatus.ready) {
      _openReady(order);
    }
  }

  void _openReady(Order order) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => OrderReadyPage(order: order),
        ),
      );
    });
  }

  Future<void> _confirmCancel(AppLocalizations loc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
        title: const Text('Annuler la commande ?'),
        content: Text(loc.cancelOrder),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Retour'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(loc.cancelOrder),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final code = await _controller!.cancel();

    if (!mounted) return;

    if (code != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.errorMessage(code))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('order_tracking_screen'),
      backgroundColor: context.surfaces.background,
      appBar: AppBar(
        title: Text(loc.yourQr),
        actions: <Widget>[
          IconButton(
            key: const Key('tracking_refresh'),
            onPressed: () => _controller!.load(widget.orderId),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: loc.refresh,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller!,
        builder: (context, _) {
          final controller = _controller!;
          final order = controller.order;

          if (controller.isLoading && order == null) {
            return const AppLoadingView();
          }

          if (controller.errorCode != null && order == null) {
            return AppStateView.error(
              title: loc.errorMessage(
                controller.errorCode ?? ApiCodes.internalError,
              ),
              message: '',
              actionLabel: loc.retry,
              onAction: () => controller.load(widget.orderId),
            );
          }

          return _TrackingBody(
            order: order!,
            loc: loc,
            onCancel: order.status.isCancelable
                ? () => _confirmCancel(loc)
                : null,
            onOpenReady: order.status == OrderStatus.ready
                ? () => _openReady(order)
                : null,
          );
        },
      ),
    );
  }
}

class _TrackingBody extends StatelessWidget {
  const _TrackingBody({
    required this.order,
    required this.loc,
    required this.onCancel,
    required this.onOpenReady,
  });

  final Order order;
  final AppLocalizations loc;
  final VoidCallback? onCancel;
  final VoidCallback? onOpenReady;

  @override
  Widget build(BuildContext context) {
    final showTimeline =
        !order.status.isTerminal &&
        order.status.index <= OrderStatus.ready.index;

    return RefreshIndicator(
      color: AppColors.pink600,
      onRefresh: () async {},
      notificationPredicate: (_) => false,
      child: ListView(
        key: const Key('tracking_scroll'),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          if (order.status == OrderStatus.ready) ...<Widget>[
            _ReadyBanner(onTap: onOpenReady, title: loc.orderReadyTitle),
            const SizedBox(height: 16),
          ],
          _OrderHero(order: order, loc: loc),
          const SizedBox(height: 16),
          _QrCard(order: order, loc: loc),
          if (order.queuePosition != null &&
              order.status == OrderStatus.queued) ...<Widget>[
            const SizedBox(height: 16),
            _QueueCard(order: order, loc: loc),
          ],
          const SizedBox(height: 16),
          _ItemsCard(order: order),
          if (showTimeline) ...<Widget>[
            const SizedBox(height: 22),
            _Timeline(status: order.status, loc: loc),
          ],
          if (onCancel != null) ...<Widget>[
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                key: const Key('order_cancel'),
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                icon: const Icon(Icons.close_rounded),
                label: Text(loc.cancelOrder),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadyBanner extends StatelessWidget {
  const _ReadyBanner({required this.onTap, required this.title});

  final VoidCallback? onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.softSuccess,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const Key('tracking_ready_banner'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.success,
                child: Icon(Icons.check_rounded, color: AppColors.neutral0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.navy900,
                    fontSize: 18,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.success),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderHero extends StatelessWidget {
  const _OrderHero({required this.order, required this.loc});

  final Order order;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final color = _trackingColor(order.status);

    return Container(
      key: const Key('tracking_order_hero'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.navy900, AppColors.blue600],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Commande #${order.number}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.neutral0,
                    fontSize: 19,
                  ),
                ),
              ),
              _StatusPill(
                label: loc.orderStatusLabel(order.status),
                color: color,
              ),
            ],
          ),
          if (order.slotLabel != null) ...<Widget>[
            const SizedBox(height: 18),
            _HeroMeta(
              icon: Icons.schedule_rounded,
              label: 'Retrait',
              value: order.slotLabel!,
            ),
          ],
          const SizedBox(height: 10),
          _HeroMeta(
            icon: Icons.payments_outlined,
            label: 'Total',
            value: Money.format(order.totalCents),
          ),
        ],
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 19, color: AppColors.pink600),
        const SizedBox(width: 9),
        Text(
          '$label : ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.neutral0.withValues(alpha: 0.72),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.neutral0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.order, required this.loc});

  final Order order;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tracking_qr_card'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surfaces.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.surfaces.border),
      ),
      child: Column(
        children: <Widget>[
          Text(
            loc.presentAtCounter,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          Semantics(
            image: true,
            label: '${loc.qrOrderSemantics} ${order.number}',
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.neutral0,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ExcludeSemantics(
                child: QrImageView(
                  data: order.number,
                  version: QrVersions.auto,
                  size: 176,
                  backgroundColor: AppColors.neutral0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF000000),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '#${order.number}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.navy900,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.order, required this.loc});

  final Order order;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tracking_queue'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.groups_2_outlined,
            color: AppColors.pink600,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${order.queuePosition} '
                  '${loc.queueAheadSuffix}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.navy900,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (order.etaMinutes != null)
                  Text(
                    '${loc.etaLabel} : '
                    '${order.etaMinutes} '
                    '${loc.minutesSuffix}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tracking_items'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaces.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.surfaces.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Votre commande',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < order.lines.length; index++) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.softPink,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${order.lines[index].quantity}x',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.pink600,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        order.lines[index].name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (order.lines[index].optionsLabel != null)
                        Text(
                          order.lines[index].optionsLabel!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (index < order.lines.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: context.surfaces.border),
              ),
          ],
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status, required this.loc});

  final OrderStatus status;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final steps = <(OrderStatus, String)>[
      (
        OrderStatus.awaitingPayment,
        loc.orderStatusLabel(OrderStatus.awaitingPayment),
      ),
      (OrderStatus.paid, loc.tlPaymentConfirmed),
      (OrderStatus.queued, loc.tlOrderReceived),
      (OrderStatus.preparing, loc.tlPreparing),
      (OrderStatus.ready, loc.tlOrderReady),
    ];

    return Container(
      key: const Key('tracking_timeline'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surfaces.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.surfaces.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Progression',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < steps.length; index++)
            _TimelineStep(
              label: steps[index].$2,
              completed: status.index > steps[index].$1.index,
              active: status.index == steps[index].$1.index,
              last: index == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.completed,
    required this.active,
    required this.last,
  });

  final String label;
  final bool completed;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? AppColors.success
        : active
        ? AppColors.pink600
        : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 24,
            child: Column(
              children: <Widget>[
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: AppColors.neutral0,
                        )
                      : null,
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: completed ? AppColors.success : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: completed || active
                      ? AppColors.navy900
                      : AppColors.muted,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.neutral0,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color _trackingColor(OrderStatus status) {
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
