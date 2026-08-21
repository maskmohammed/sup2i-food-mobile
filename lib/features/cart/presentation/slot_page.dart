import 'package:flutter/material.dart';

import '../../../app/cart_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../data/slot_repository.dart';
import '../domain/time_slot.dart';

/// Écran « Choisir un créneau ». Les créneaux et leurs états viennent du
/// serveur (jamais calculés localement) ; un créneau complet/fermé n'est pas
/// sélectionnable (codes serveur SLOT_FULL / SLOT_CLOSED à la validation).
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: slots.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final slot = slots[index];
        return _SlotTile(
          slot: slot,
          selected: slot.id == selectedId,
          onTap: slot.selectable
              ? () {
                  CartScope.of(context, listen: false).selectSlot(slot);
                  Navigator.of(context).pop();
                }
              : null,
        );
      },
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.slot, required this.selected, this.onTap});

  final TimeSlot slot;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Opacity(
      opacity: slot.selectable ? 1 : 0.5,
      child: Material(
        color: AppColors.neutral0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppColors.pink600 : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(slot.label, style: text.bodyLarge),
                      const SizedBox(height: 4),
                      _StatusBadge(status: slot.status, loc: loc),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
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
    final (String label, Color color) = switch (status) {
      SlotStatus.available => (loc.slotAvailable, AppColors.success),
      SlotStatus.almostFull => (loc.slotAlmostFull, AppColors.warning),
      SlotStatus.full => (loc.slotFull, AppColors.error),
      SlotStatus.closed => (loc.slotClosed, AppColors.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
