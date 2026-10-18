import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/brand_chef_mascot.dart';
import '../../../l10n/app_localizations.dart';
import '../data/canteen_repository.dart';
import '../domain/canteen.dart';

/// Reservation confirmation.
///
/// The server remains authoritative when cancellation is requested.
class ReservationConfirmedPage extends StatefulWidget {
  const ReservationConfirmedPage({
    super.key,
    required this.reservation,
    this.repository,
  });

  final Reservation reservation;
  final CanteenRepository? repository;

  @override
  State<ReservationConfirmedPage> createState() =>
      _ReservationConfirmedPageState();
}

class _ReservationConfirmedPageState extends State<ReservationConfirmedPage> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    if (_cancelling) return;

    setState(() => _cancelling = true);

    final repo = widget.repository ?? const MockCanteenRepository();

    try {
      await repo.cancelReservation(widget.reservation.id);

      if (!mounted) return;
      Navigator.of(context).pop();
    } on Object {
      if (!mounted) return;

      setState(() => _cancelling = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L annulation n a pas pu etre effectuee.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final reservation = widget.reservation;

    return Scaffold(
      key: const Key('reservation_confirmed_screen'),
      backgroundColor: context.surfaces.background,
      appBar: AppBar(title: Text(loc.reservationConfirmedTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: <Widget>[
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 124,
                  height: 124,
                  decoration: const BoxDecoration(
                    color: AppColors.softSuccess,
                    shape: BoxShape.circle,
                  ),
                ),
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.success,
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.neutral0,
                    size: 38,
                  ),
                ),
                const Positioned(
                  right: -30,
                  bottom: -18,
                  child: BrandChefMascot(width: 70, height: 82),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            loc.reservationConfirmedTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(
            loc.reservationSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 22),
          Container(
            key: const Key('reservation_summary'),
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
                  reservation.mealLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.menuOfDay,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                Divider(color: context.surfaces.border),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: reservation.dateLabel,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.schedule_rounded,
                  label:
                      '${loc.cancelPossibleUntil} '
                      '${reservation.cancelDeadlineLabel}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              key: const Key('reservation_cancel'),
              onPressed: _cancelling ? null : _cancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              icon: _cancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.error,
                      ),
                    )
                  : const Icon(Icons.close_rounded),
              label: Text(loc.cancelReservation),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: FilledButton(
              key: const Key('reservation_back'),
              onPressed: _cancelling ? null : () => Navigator.of(context).pop(),
              child: Text(loc.backToCanteen),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'La possibilite d annuler doit etre validee '
            'par le serveur au moment de la demande.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.softPink,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.pink600, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.navy900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
