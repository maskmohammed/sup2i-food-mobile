import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/canteen_controller.dart';
import '../data/canteen_repository.dart';
import '../domain/canteen.dart';
import 'loss_declaration_page.dart';

/// Digital counterpart of the official SUP2I FOOD Food Pass.
///
/// Identity, status and QR payload are repository/server authority.
class FoodPassPage extends StatefulWidget {
  const FoodPassPage({super.key, this.repository});

  final CanteenRepository? repository;

  @override
  State<FoodPassPage> createState() => _FoodPassPageState();
}

class _FoodPassPageState extends State<FoodPassPage> {
  late final CanteenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CanteenController(
      widget.repository ?? const MockCanteenRepository(),
    )..loadFoodPass();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _statusColor(FoodPassStatus status) {
    switch (status) {
      case FoodPassStatus.active:
        return AppColors.success;
      case FoodPassStatus.blocked:
      case FoodPassStatus.revoked:
        return AppColors.error;
      case FoodPassStatus.lost:
      case FoodPassStatus.expired:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('food_pass_screen'),
      backgroundColor: context.surfaces.background,
      appBar: AppBar(title: Text(loc.foodPassPageTitle)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final pass = _controller.foodPass;

          if (_controller.isLoading && pass == null) {
            return const AppLoadingView();
          }

          if (_controller.errorCode != null && pass == null) {
            return AppStateView.error(
              title: loc.errorMessage(
                _controller.errorCode ?? ApiCodes.internalError,
              ),
              message: '',
              actionLabel: loc.retry,
              onAction: _controller.loadFoodPass,
            );
          }

          final foodPass = pass!;
          final active = foodPass.status == FoodPassStatus.active;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: <Widget>[
              _PassCard(
                pass: foodPass,
                statusColor: _statusColor(foodPass.status),
                statusLabel: loc.foodPassStatusLabel(foodPass.status),
                idLabel: loc.foodPassIdLabel,
                qrLabel: loc.qrFoodPassSemantics,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: active ? AppColors.softSuccess : AppColors.softWarning,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      active
                          ? Icons.verified_rounded
                          : Icons.info_outline_rounded,
                      color: active ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        active
                            ? 'Votre Food Pass est actif.'
                            : 'Le statut affiche vient du serveur. '
                                  'Le QR ne doit pas etre utilise si le pass '
                                  'est perdu, bloque, expire ou revoque.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.navy900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (active) ...<Widget>[
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    key: const Key('declare_loss'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LossDeclarationPage(
                            repository: widget.repository,
                          ),
                        ),
                      );

                      if (!mounted) return;
                      await _controller.loadFoodPass();
                    },
                    icon: const Icon(Icons.report_gmailerrorred_rounded),
                    label: Text(loc.declareLossButton),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PassCard extends StatelessWidget {
  const _PassCard({
    required this.pass,
    required this.statusColor,
    required this.statusLabel,
    required this.idLabel,
    required this.qrLabel,
  });

  final FoodPass pass;
  final Color statusColor;
  final String statusLabel;
  final String idLabel;
  final String qrLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('food_pass_card'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.navy900, AppColors.blue600],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x29161B5C),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -54,
            top: -54,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.pink600.withValues(alpha: 0.32),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 54,
                      height: 54,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.neutral0,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        'assets/images/sup2i_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.restaurant_menu_rounded,
                            color: AppColors.pink600,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'FOOD PASS',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.neutral0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  pass.studentName,
                  key: const Key('food_pass_name'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.neutral0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$idLabel : ${pass.studentId}',
                  key: const Key('food_pass_id'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral0.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 22),
                Center(
                  child: Semantics(
                    image: true,
                    label: qrLabel,
                    child: Container(
                      key: const Key('food_pass_qr'),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.neutral0,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ExcludeSemantics(
                        child: QrImageView(
                          data: pass.qrPayload,
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
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'SUP2I FOOD',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.pink600,
                      fontWeight: FontWeight.w800,
                    ),
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
