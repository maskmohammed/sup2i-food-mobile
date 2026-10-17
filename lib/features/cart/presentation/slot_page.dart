import 'package:flutter/material.dart';

import '../../../app/cart_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../data/slot_repository.dart';
import '../domain/time_slot.dart';

/// Pickup slot selection.
///
/// Slot availability is displayed from repository/server state only. The UI
/// never computes capacity locally.
class SlotPage extends StatefulWidget {
  const SlotPage({super.key, this.repository});

  final SlotRepository? repository;

  @override
  State<SlotPage> createState() => _SlotPageState();
}

class _SlotPageState extends State<SlotPage> {
  late final SlotRepository _repository;
  List<TimeSlot>? _slots;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? const MockSlotRepository();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final slots = await _repository.slots();
      if (!mounted) return;

      setState(() {
        _slots = slots;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;

      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('slot_screen'),
      backgroundColor: context.surfaces.background,
      appBar: AppBar(title: Text(loc.chooseSlot)),
      body: _buildBody(loc),
    );
  }

  Widget _buildBody(AppLocalizations loc) {
    if (_loading) return const AppLoadingView();

    if (_error) {
      return AppStateView.error(
        title: loc.errorMessage(ApiCodes.internalError),
        message: '',
        actionLabel: loc.retry,
        onAction: _load,
      );
    }

    final slots = _slots ?? const <TimeSlot>[];
    final selectedId = CartScope.of(context).slot?.id;

    return RefreshIndicator(
      color: AppColors.pink600,
      onRefresh: _load,
      child: ListView(
        key: const Key('slot_list'),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          _SlotIntro(title: loc.chooseSlot),
          const SizedBox(height: 18),
          for (final slot in slots) ...<Widget>[
            _SlotCard(
              slot: slot,
              selected: slot.id == selectedId,
              onTap: slot.selectable
                  ? () {
                      CartScope.of(context, listen: false).selectSlot(slot);
                      Navigator.of(context).pop();
                    }
                  : null,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SlotIntro extends StatelessWidget {
  const _SlotIntro({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.navy900, AppColors.blue600],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.neutral0,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: AppColors.pink600,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.neutral0,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'La disponibilite affichee vient du serveur.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral0.withValues(alpha: 0.76),
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

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot, required this.selected, this.onTap});

  final TimeSlot slot;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Opacity(
      opacity: slot.selectable ? 1 : 0.56,
      child: Material(
        color: selected ? AppColors.softPink : context.surfaces.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? AppColors.pink600 : context.surfaces.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.pink600
                        : context.surfaces.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    color: selected ? AppColors.neutral0 : AppColors.navy900,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        slot.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.navy900,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _StatusBadge(status: slot.status, loc: loc),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.pink600 : AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.loc});

  final SlotStatus status;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;

    switch (status) {
      case SlotStatus.available:
        label = loc.slotAvailable;
        color = AppColors.success;
      case SlotStatus.almostFull:
        label = loc.slotAlmostFull;
        color = AppColors.warning;
      case SlotStatus.full:
        label = loc.slotFull;
        color = AppColors.error;
      case SlotStatus.closed:
        label = loc.slotClosed;
        color = AppColors.muted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
