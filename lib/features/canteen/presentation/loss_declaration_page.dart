import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/canteen_repository.dart';
import '../domain/canteen.dart';

/// Déclaration de perte du Food Pass — **action irréversible** confirmée
/// serveur (ancien QR invalidé ; abonnement/quota/historique conservés).
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
    setState(() => _loading = true);
    final repo = widget.repository ?? const MockCanteenRepository();
    await repo.declareLoss(_reason);
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.lossDeclared)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.lossTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.lossIrreversibleTitle,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(loc.lossIrreversibleBody, style: text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(loc.lossReasonQuestion, style: text.titleLarge),
          const SizedBox(height: 8),
          for (final reason in LossReason.values)
            _ReasonTile(
              label: loc.lossReasonLabel(reason),
              selected: _reason == reason,
              onTap: () => setState(() => _reason = reason),
            ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.neutral0,
              ),
              onPressed: _loading ? null : () => _confirm(loc),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.neutral0,
                      ),
                    )
                  : Text(loc.confirmLoss),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: AppColors.neutral0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.pink600 : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? AppColors.pink600 : AppColors.muted,
        ),
        title: Text(label),
      ),
    );
  }
}
