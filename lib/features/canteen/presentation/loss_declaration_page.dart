import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../l10n/app_localizations.dart';
import '../data/canteen_repository.dart';
import '../domain/canteen.dart';

/// Irreversible Food Pass loss declaration.
///
/// The repository/server invalidates the old QR while preserving rights,
/// subscription, quota and history.
class LossDeclarationPage extends StatefulWidget {
  const LossDeclarationPage({super.key, this.repository});

  final CanteenRepository? repository;

  @override
  State<LossDeclarationPage> createState() => _LossDeclarationPageState();
}

class _LossDeclarationPageState extends State<LossDeclarationPage> {
  LossReason _reason = LossReason.lost;
  bool _loading = false;

  Future<void> _confirm(AppLocalizations loc) async {
    if (_loading) return;

    setState(() => _loading = true);

    final repo = widget.repository ?? const MockCanteenRepository();

    try {
      await repo.declareLoss(_reason);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.lossDeclared)));

      Navigator.of(context).pop();
    } on Object {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La declaration n a pas pu etre enregistree.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('loss_screen'),
      backgroundColor: context.surfaces.background,
      appBar: AppBar(title: Text(loc.lossTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: <Widget>[
          Container(
            key: const Key('loss_warning'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: <Widget>[
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.error,
                  child: Icon(
                    Icons.report_gmailerrorred_rounded,
                    color: AppColors.neutral0,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  loc.lossIrreversibleTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.error,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  loc.lossIrreversibleBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.navy900),
                ),
                const SizedBox(height: 10),
                Text(
                  'L ancien QR sera invalide. '
                  'Vos droits, quota et historique restent conserves.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.lossReasonQuestion,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          for (final reason in LossReason.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReasonCard(
                label: loc.lossReasonLabel(reason),
                selected: _reason == reason,
                enabled: !_loading,
                onTap: () => setState(() => _reason = reason),
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              key: const Key('loss_confirm'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: _loading ? null : () => _confirm(loc),
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: AppColors.neutral0,
                      ),
                    )
                  : const Icon(Icons.warning_amber_rounded),
              label: Text(loc.confirmLoss),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.softPink : context.surfaces.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.pink600 : context.surfaces.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.pink600 : AppColors.muted,
              ),
              const SizedBox(width: 12),
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
          ),
        ),
      ),
    );
  }
}
