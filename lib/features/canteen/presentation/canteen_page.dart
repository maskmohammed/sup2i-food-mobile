import 'package:flutter/material.dart';

import '../../../app/app_bar_actions.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../core/widgets/brand_chef_mascot.dart';
import '../../../l10n/app_localizations.dart';
import '../application/canteen_controller.dart';
import '../data/canteen_repository.dart';
import '../domain/canteen.dart';
import 'food_pass_page.dart';
import 'reservation_confirmed_page.dart';
import 'subscription_page.dart';

/// Final Cantine experience.
///
/// Menu and reservation eligibility remain repository/server authority.
class CanteenPage extends StatefulWidget {
  const CanteenPage({super.key, this.repository});

  final CanteenRepository? repository;

  @override
  State<CanteenPage> createState() => _CanteenPageState();
}

class _CanteenPageState extends State<CanteenPage> {
  late final CanteenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CanteenController(
      widget.repository ?? const MockCanteenRepository(),
    )..loadMenu();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _reserve(String mealId) async {
    final loc = AppLocalizations.of(context);
    final reservation = await _controller.reserve(mealId);

    if (!mounted) return;

    if (reservation != null) {
      _push(
        ReservationConfirmedPage(
          reservation: reservation,
          repository: widget.repository,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.errorMessage(_controller.errorCode ?? ApiCodes.internalError),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('canteen_screen'),
      backgroundColor: context.surfaces.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.isLoading && _controller.menu.isEmpty) {
              return const AppLoadingView();
            }

            if (_controller.errorCode != null && _controller.menu.isEmpty) {
              return AppStateView.error(
                title: loc.errorMessage(
                  _controller.errorCode ?? ApiCodes.internalError,
                ),
                message: '',
                actionLabel: loc.retry,
                onAction: _controller.loadMenu,
              );
            }

            return RefreshIndicator(
              color: AppColors.pink600,
              onRefresh: _controller.loadMenu,
              child: ListView(
                key: const Key('canteen_scroll'),
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  _CanteenHeader(title: loc.navCanteen),
                  const SizedBox(height: 18),
                  _CanteenHero(
                    onFoodPass: () =>
                        _push(FoodPassPage(repository: widget.repository)),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _QuickCard(
                            key: const Key('canteen_food_pass'),
                            icon: Icons.qr_code_2_rounded,
                            title: loc.foodPassButton,
                            subtitle: 'QR et statut',
                            onTap: () => _push(
                              FoodPassPage(repository: widget.repository),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickCard(
                            key: const Key('canteen_subscription'),
                            icon: Icons.card_membership_rounded,
                            title: loc.subscriptionButton,
                            subtitle: 'Quota et historique',
                            onTap: () => _push(
                              SubscriptionPage(repository: widget.repository),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Menu de la semaine',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 19),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final meal in _controller.menu)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _MealCard(
                        meal: meal,
                        onTap: () => _reserve(meal.id),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CanteenHeader extends StatelessWidget {
  const _CanteenHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('canteen_header'),
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
                  'Repas, reservations et Food Pass.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const AppBarActions(),
        ],
      ),
    );
  }
}

class _CanteenHero extends StatelessWidget {
  const _CanteenHero({required this.onFoodPass});

  final VoidCallback onFoodPass;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('canteen_hero'),
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.navy900, AppColors.blue600],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -28,
            top: -44,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: AppColors.pink600,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            right: 2,
            bottom: -6,
            child: BrandChefMascot(width: 130, height: 148),
          ),
          Positioned(
            left: 20,
            top: 22,
            right: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Votre repas campus',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.neutral0,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Accedez rapidement a votre Food Pass.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral0.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: FilledButton(
                    key: const Key('canteen_hero_action'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.neutral0,
                      foregroundColor: AppColors.navy900,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: onFoodPass,
                    child: const Text('Afficher mon pass'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaces.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.surfaces.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.softPink,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.pink600),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.navy900,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onTap});

  final MealDay meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaces.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.surfaces.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.softPink, AppColors.softBlue],
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.lunch_dining_rounded,
                  size: 34,
                  color: AppColors.pink600,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      meal.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.navy900,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (meal.description != null) ...<Widget>[
                      const SizedBox(height: 5),
                      Text(
                        meal.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                    const SizedBox(height: 9),
                    Text(
                      'Reserver',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.pink600,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
