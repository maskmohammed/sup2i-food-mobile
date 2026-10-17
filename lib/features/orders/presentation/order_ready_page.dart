import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/widgets/brand_chef_mascot.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/order.dart';

/// Full-screen READY success state.
///
/// The QR remains high-contrast black on white for scanning. Motion obeys the
/// existing reduced-motion preference.
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
    end: 1.07,
  ).animate(CurvedAnimation(parent: _pulse, curve: AppMotion.standard));

  @override
  void initState() {
    super.initState();
    AppHaptics.success();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!AppMotion.reduceMotion(context) && !_pulse.isAnimating) {
      _runPulse();
    }
  }

  Future<void> _runPulse() async {
    for (var index = 0; index < 3; index++) {
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
    final loc = AppLocalizations.of(context);
    final order = widget.order;

    return Scaffold(
      key: const Key('order_ready_screen'),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[AppColors.navy900, AppColors.blue600],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: IconButton(
                    key: const Key('ready_close_top'),
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: loc.orderReadyClose,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.neutral0,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                color: AppColors.softSuccess,
                                shape: BoxShape.circle,
                              ),
                            ),
                            ScaleTransition(
                              scale: _scale,
                              child: const CircleAvatar(
                                radius: 34,
                                backgroundColor: AppColors.success,
                                child: Icon(
                                  Icons.check_rounded,
                                  color: AppColors.neutral0,
                                  size: 40,
                                ),
                              ),
                            ),
                            const Positioned(
                              right: -32,
                              bottom: -20,
                              child: BrandChefMascot(width: 72, height: 84),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        Text(
                          loc.orderReadyTitle,
                          key: const Key('ready_title'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.neutral0,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.orderReadySubtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.neutral0.withValues(
                                  alpha: 0.78,
                                ),
                              ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.neutral0,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Column(
                            children: <Widget>[
                              Semantics(
                                image: true,
                                label:
                                    '${loc.qrOrderSemantics} ${order.number}',
                                child: ExcludeSemantics(
                                  child: QrImageView(
                                    data: order.number,
                                    version: QrVersions.auto,
                                    size: 196,
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
                              const SizedBox(height: 12),
                              Text(
                                loc.orderNumberLabel,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.muted),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '#${order.number}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.navy900,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              if (order.slotLabel != null) ...<Widget>[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.softPink,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Retrait ${order.slotLabel}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: AppColors.pink600,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    key: const Key('ready_close'),
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.neutral0,
                      foregroundColor: AppColors.navy900,
                    ),
                    child: Text(loc.orderReadyClose),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
