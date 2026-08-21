import 'package:flutter/material.dart';

import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/canteen_controller.dart';
import '../data/canteen_repository.dart';
import '../domain/canteen.dart';
import 'loss_declaration_page.dart';

/// Food Pass numérique : carte navy avec QR permanent, identité et statut
/// (badge + libellé). Photo/état pilotés serveur ; la photo n'est jamais
/// modifiable côté Mobile.
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

  Color _statusColor(FoodPassStatus status) => switch (status) {
    FoodPassStatus.active => AppColors.success,
    FoodPassStatus.blocked || FoodPassStatus.revoked => AppColors.error,
    FoodPassStatus.lost || FoodPassStatus.expired => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
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
          final fp = pass!;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.navy900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SUP2I FOOD — FOOD PASS',
                    style: text.labelSmall?.copyWith(color: AppColors.neutral0),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fp.studentName,
                    style: text.headlineSmall?.copyWith(
                      color: AppColors.neutral0,
                    ),
                  ),
                  Text(
                    '${loc.foodPassIdLabel} : ${fp.studentId}',
                    style: text.bodySmall?.copyWith(
                      color: AppColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(fp.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loc.foodPassStatusLabel(fp.status),
                      style: text.labelSmall?.copyWith(
                        color: AppColors.neutral0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.neutral0,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        size: 110,
                        color: AppColors.navy900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LossDeclarationPage(
                            repository: widget.repository,
                          ),
                        ),
                      ),
                      child: Text(
                        loc.declareLossButton,
                        style: const TextStyle(color: AppColors.neutral0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
