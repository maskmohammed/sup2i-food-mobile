import 'package:flutter/material.dart';

import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/canteen_controller.dart';
import '../data/canteen_repository.dart';
import '../domain/canteen.dart';

/// Abonnement / quota cantine. Abonnement **activé par l'Administration** ;
/// quota calculé serveur (renouvellement hebdomadaire). Lecture seule.
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
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.subscriptionPageTitle)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final sub = _controller.subscription;
          if (_controller.isLoading && sub == null) {
            return const AppLoadingView();
          }
          if (_controller.errorCode != null && sub == null) {
            return AppStateView.error(
              title: loc.errorMessage(
                _controller.errorCode ?? ApiCodes.internalError,
              ),
              message: '',
              actionLabel: loc.retry,
              onAction: _controller.loadSubscription,
            );
          }
          return _Body(subscription: sub!, loc: loc);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.subscription, required this.loc});

  final Subscription subscription;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final s = subscription;
    final progress = s.quotaTotal == 0 ? 0.0 : s.quotaRemaining / s.quotaTotal;
    String two(int n) => n.toString().padLeft(2, '0');
    final validUntil =
        '${two(s.validUntil.day)}/${two(s.validUntil.month)}/${s.validUntil.year}';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.navy900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.planName,
                style: text.headlineSmall?.copyWith(color: AppColors.neutral0),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: s.active ? AppColors.success : AppColors.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s.active ? loc.planActive : loc.planInactive,
                  style: text.labelSmall?.copyWith(color: AppColors.neutral0),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${loc.validUntilLabel} $validUntil',
                style: text.bodySmall?.copyWith(color: AppColors.neutral100),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            '${s.quotaRemaining} / ${s.quotaTotal}',
            style: text.displayLarge?.copyWith(color: AppColors.navy900),
          ),
        ),
        Center(
          child: Text(
            loc.quotaRemainingLabel,
            style: text.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.neutral100,
            color: AppColors.pink600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          loc.renewsMonday,
          style: text.bodySmall?.copyWith(color: AppColors.muted),
        ),
        if (s.historyWeekLabel != null) ...[
          const SizedBox(height: 24),
          Text(loc.historyLabel, style: text.titleLarge),
          const SizedBox(height: 8),
          Text(s.historyWeekLabel!, style: text.bodyMedium),
          Text(
            '${s.historyUsed}/${s.historyTotal} ${loc.mealsUsedSuffix}',
            style: text.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}
