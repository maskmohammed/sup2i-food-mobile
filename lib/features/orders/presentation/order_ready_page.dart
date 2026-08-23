import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/order.dart';

/// Écran dédié plein écran « commande prête ».
///
/// Affiché quand une commande passe au statut READY (poussé en fullscreen
/// depuis le suivi). Met en avant le QR de retrait à présenter au comptoir.
/// Le check fait une pulsation d'attention (charte : 250–400 ms, bornée à
/// quelques cycles), désactivée si `prefers-reduced-motion`.
class OrderReadyPage extends StatefulWidget {
  const OrderReadyPage({super.key, required this.order});

  final Order order;

  @override
  State<OrderReadyPage> createState() => _OrderReadyPageState();
}

class _OrderReadyPageState extends State<OrderReadyPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.pulse,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1,
    end: 1.08,
  ).animate(CurvedAnimation(parent: _pulse, curve: AppMotion.standard));

  @override
  void initState() {
    super.initState();
    // « Commande prête » : moment succès du parcours (l'app présente le QR, elle
    // ne le scanne pas). Haptique supplémentaire — l'écran reste la confirmation.
    AppHaptics.success();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AppMotion.reduceMotion(context) && !_pulse.isAnimating) {
      _runPulse();
    }
  }

  /// Quelques cycles de pulsation puis retour au repos (auto-terminant : ne
  /// bloque pas `pumpAndSettle`).
  Future<void> _runPulse() async {
    for (var i = 0; i < 3; i++) {
      if (!mounted) return;
      await _pulse.forward(from: 0);
      if (!mounted) return;
      await _pulse.reverse();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final order = widget.order;

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
                        ScaleTransition(
                          scale: _scale,
                          child: const CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.neutral0,
                            child: Icon(
                              Icons.check_rounded,
                              color: AppColors.success,
                              size: 52,
                            ),
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
                        Semantics(
                          image: true,
                          label: '${loc.qrOrderSemantics} ${order.number}',
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.neutral0,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ExcludeSemantics(
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
