import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/order.dart';

/// Écran dédié plein écran « commande prête ».
///
/// Affiché quand une commande passe au statut READY (poussé en fullscreen
/// depuis le suivi). Met en avant le QR de retrait à présenter au comptoir.
/// L'animation de pulsation (charte) est ajoutée au point 7.
class OrderReadyPage extends StatelessWidget {
  const OrderReadyPage({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.success,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close, color: AppColors.neutral0),
                  tooltip: loc.orderReadyClose,
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.neutral0,
                          child: Icon(
                            Icons.check_rounded,
                            color: AppColors.success,
                            size: 52,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          loc.orderReadyTitle,
                          textAlign: TextAlign.center,
                          style: text.headlineMedium?.copyWith(
                            color: AppColors.neutral0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.orderReadySubtitle,
                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(
                            color: AppColors.neutral0,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // QR de retrait — zone blanche dégagée, non décoré
                        // (charte), reste blanc pour la scannabilité.
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.neutral0,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: order.number,
                            version: QrVersions.auto,
                            size: 200,
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
                        const SizedBox(height: 20),
                        Text(
                          loc.orderNumberLabel,
                          style: text.bodySmall?.copyWith(
                            color: AppColors.neutral0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.number,
                          style: text.displaySmall?.copyWith(
                            color: AppColors.neutral0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.neutral0,
                    foregroundColor: AppColors.success,
                  ),
                  child: Text(loc.orderReadyClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
