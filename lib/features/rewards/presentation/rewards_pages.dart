import 'package:flutter/material.dart';

import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/rewards_controller.dart';
import '../data/rewards_repository.dart';
import '../domain/rewards.dart';

/// Écran Promotions (offres actives). Prix/règles restent autorité serveur.
class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key, this.repository});

  final RewardsRepository? repository;

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  late final RewardsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RewardsController(
      widget.repository ?? const MockRewardsRepository(),
    )..loadPromotions();
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
      appBar: AppBar(title: Text(loc.promotionsTitle)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.promotions.isEmpty) {
            return const AppLoadingView();
          }
          if (_controller.errorCode != null && _controller.promotions.isEmpty) {
            return AppStateView.error(
              title: loc.errorMessage(
                _controller.errorCode ?? ApiCodes.internalError,
              ),
              message: '',
              actionLabel: loc.retry,
              onAction: _controller.loadPromotions,
            );
          }
          if (_controller.promotions.isEmpty) {
            return AppStateView.empty(
              icon: Icons.local_offer_outlined,
              title: loc.promotionsEmpty,
              message: '',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.promotions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _PromoCard(promo: _controller.promotions[index]),
          );
        },
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo});

  final Promotion promo;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaces.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.surfaces.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.title, style: text.bodyLarge),
                const SizedBox(height: 4),
                Text(
                  promo.description,
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (promo.badgeLabel != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.pink600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                promo.badgeLabel!,
                style: text.labelSmall?.copyWith(color: AppColors.neutral0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Écran Fidélité : solde de points + historique.
class LoyaltyPage extends StatefulWidget {
  const LoyaltyPage({super.key, this.repository});

  final RewardsRepository? repository;

  @override
  State<LoyaltyPage> createState() => _LoyaltyPageState();
}

class _LoyaltyPageState extends State<LoyaltyPage> {
  late final RewardsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RewardsController(
      widget.repository ?? const MockRewardsRepository(),
    )..loadLoyalty();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.loyaltyTitle)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final balance = _controller.loyalty;
          if (_controller.isLoading && balance == null) {
            return const AppLoadingView();
          }
          if (_controller.errorCode != null && balance == null) {
            return AppStateView.error(
              title: loc.errorMessage(
                _controller.errorCode ?? ApiCodes.internalError,
              ),
              message: '',
              actionLabel: loc.retry,
              onAction: _controller.loadLoyalty,
            );
          }
          final b = balance!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.navy900,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${b.points}',
                      style: text.displayLarge?.copyWith(
                        color: AppColors.neutral0,
                      ),
                    ),
                    Text(
                      '${loc.loyaltyPointsLabel} · ${b.tierLabel}',
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(loc.historyLabel, style: text.titleLarge),
              const SizedBox(height: 8),
              for (final entry in _controller.history)
                _HistoryRow(entry: entry),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final LoyaltyEntry entry;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final positive = entry.points >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.label, style: text.bodyMedium),
                Text(
                  entry.dateLabel,
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            '${positive ? '+' : ''}${entry.points}',
            style: text.labelLarge?.copyWith(
              color: positive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
