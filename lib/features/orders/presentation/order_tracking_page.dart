import 'package:flutter/material.dart';

import '../../../app/orders_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/order_tracking_controller.dart';
import '../data/order_repository.dart';
import '../domain/order.dart';

/// Suivi d'une commande : QR de retrait, statut, timeline, annulation.
/// La progression réelle des statuts est pilotée serveur (temps réel = M7).
class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key, required this.orderId, this.repository});

  final String orderId;
  final OrderRepository? repository;

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  OrderTrackingController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final repo = widget.repository ?? OrdersScope.of(context);
      _controller = OrderTrackingController(repo)..load(widget.orderId);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _confirmCancel(AppLocalizations loc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(loc.cancelOrder),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.retry),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.cancelOrder),
          ),
        ],
      ),
    );
    if (ok != true) return;
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
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.yourQr),
        actions: [
          IconButton(
            onPressed: () => _controller!.load(widget.orderId),
            icon: const Icon(Icons.refresh),
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
  });

  final Order order;
  final AppLocalizations loc;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final showTimeline =
        !order.status.isTerminal &&
        order.status.index <= OrderStatus.ready.index;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (order.status == OrderStatus.ready) ...[
          Column(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.success,
                child: Icon(Icons.check, color: AppColors.neutral0, size: 40),
              ),
              const SizedBox(height: 12),
              Text(
                loc.orderReadyTitle,
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(color: AppColors.navy900),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        // QR de retrait (rendu réel via une lib QR à ajouter ultérieurement).
        Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 120,
              color: AppColors.navy900,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(child: _StatusBadge(label: loc.orderStatusLabel(order.status))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.navy900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                loc.orderNumberLabel,
                style: text.bodySmall?.copyWith(color: AppColors.neutral0),
              ),
              const SizedBox(height: 4),
              Text(
                order.number,
                style: text.headlineLarge?.copyWith(color: AppColors.neutral0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.presentAtCounter,
          textAlign: TextAlign.center,
          style: text.bodySmall?.copyWith(color: AppColors.muted),
        ),
        if (order.status == OrderStatus.queued &&
            order.queuePosition != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pink500.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${order.queuePosition} ${loc.queueAheadSuffix}',
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (order.etaMinutes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${loc.etaLabel} : ${order.etaMinutes} ${loc.minutesSuffix}',
                    style: text.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (showTimeline) ...[
          const SizedBox(height: 24),
          _Timeline(status: order.status, loc: loc),
        ],
        if (onCancel != null) ...[
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: Text(loc.cancelOrder),
            ),
          ),
        ],
      ],
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
      (OrderStatus.paid, loc.tlPaymentConfirmed),
      (OrderStatus.queued, loc.tlOrderReceived),
      (OrderStatus.preparing, loc.tlPreparing),
      (OrderStatus.ready, loc.tlOrderReady),
    ];
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (step, label) in steps)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                _dot(status.index, step.index),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: status.index == step.index
                      ? text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
                      : text.bodyMedium?.copyWith(
                          color: status.index > step.index
                              ? AppColors.neutral900
                              : AppColors.muted,
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _dot(int statusIndex, int stepIndex) {
    final Color color;
    if (statusIndex > stepIndex) {
      color = AppColors.success;
    } else if (statusIndex == stepIndex) {
      color = AppColors.pink600;
    } else {
      color = AppColors.border;
    }
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.blue600.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.blue600),
      ),
    );
  }
}
