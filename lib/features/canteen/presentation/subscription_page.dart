import 'package:flutter/material.dart';

import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/canteen_controller.dart';
import '../data/canteen_repository.dart';
import '../domain/canteen.dart';

/// Read-only canteen subscription.
///
/// Activation and quota are server authority.
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key, this.repository});

  final CanteenRepository? repository;

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late final CanteenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CanteenController(
      widget.repository ?? const MockCanteenRepository(),
    )..loadSubscription();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('subscription_screen'),
      backgroundColor: context.surfaces.background,
      appBar: AppBar(title: Text(loc.subscriptionPageTitle)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final subscription = _controller.subscription;

          if (_controller.isLoading && subscription == null) {
            return const AppLoadingView();
          }

          if (_controller.errorCode != null && subscription == null) {
            return AppStateView.error(
              title: loc.errorMessage(
                _controller.errorCode ?? ApiCodes.internalError,
              ),
              message: '',
              actionLabel: loc.retry,
              onAction: _controller.loadSubscription,
            );
          }

          return _SubscriptionBody(subscription: subscription!, loc: loc);
        },
      ),
    );
  }
}

class _SubscriptionBody extends StatelessWidget {
  const _SubscriptionBody({required this.subscription, required this.loc});

  final Subscription subscription;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    final rawProgress = s.quotaTotal == 0
        ? 0.0
        : s.quotaRemaining / s.quotaTotal;
    final progress = rawProgress.clamp(0.0, 1.0).toDouble();

    String two(int value) => value.toString().padLeft(2, '0');

    final validUntil =
        '${two(s.validUntil.day)}/'
        '${two(s.validUntil.month)}/'
        '${s.validUntil.year}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      children: <Widget>[
        Container(
          key: const Key('subscription_card'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppColors.navy900, AppColors.blue600],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.neutral0,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_membership_rounded,
                      color: AppColors.pink600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.planName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.neutral0,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: s.active ? AppColors.success : AppColors.muted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  s.active ? loc.planActive : loc.planInactive,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${loc.validUntilLabel} $validUntil',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral0.withValues(alpha: 0.76),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          key: const Key('subscription_quota'),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.surfaces.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.surfaces.border),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      loc.quotaRemainingLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                  ),
                  Text(
                    '${s.quotaRemaining} / ${s.quotaTotal}',
                    key: const Key('subscription_quota_value'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.pink600,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: context.surfaces.background,
                  color: AppColors.pink600,
                ),
              ),
              const SizedBox(height: 9),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  loc.renewsMonday,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
        if (s.historyWeekLabel != null) ...<Widget>[
          const SizedBox(height: 20),
          Container(
            key: const Key('subscription_history'),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.surfaces.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: context.surfaces.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.historyLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.softPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: AppColors.pink600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            s.historyWeekLabel!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (s.historyUsed != null && s.historyTotal != null)
                            Text(
                              '${s.historyUsed}/'
                              '${s.historyTotal} '
                              '${loc.mealsUsedSuffix}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Text(
          'Abonnement et quota sont geres par '
          'l administration et le serveur.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
