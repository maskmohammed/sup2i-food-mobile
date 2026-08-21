import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../l10n/app_localizations.dart';
import '../data/canteen_repository.dart';
import '../domain/canteen.dart';

/// Confirmation de réservation cantine. Annulation possible **avant l'heure
/// limite** (donnée serveur) ; passé ce délai, le bouton disparaît.
class ReservationConfirmedPage extends StatelessWidget {
  const ReservationConfirmedPage({
    super.key,
    required this.reservation,
    this.repository,
  });

  final Reservation reservation;
  final CanteenRepository? repository;

  Future<void> _cancel(BuildContext context) async {
    final repo = repository ?? const MockCanteenRepository();
    await repo.cancelReservation(reservation.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.reservationConfirmedTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.success,
              child: Icon(Icons.check, color: AppColors.neutral0, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.reservationConfirmedTitle,
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            loc.reservationSubtitle,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surfaces.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.surfaces.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reservation.mealLabel, style: text.bodyLarge),
                Text(
                  loc.menuOfDay,
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reservation.dateLabel,
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${loc.cancelPossibleUntil} ${reservation.cancelDeadlineLabel}',
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => _cancel(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: Text(loc.cancelReservation),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.backToCanteen),
            ),
          ),
        ],
      ),
    );
  }
}
