import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/order.dart';

/// Ouvre la feuille de choix du moyen de paiement (CASH / CARD_TPE).
/// Retourne le moyen choisi, ou `null` si annulé.
Future<PaymentMethod?> showPaymentMethodSheet(BuildContext context) {
  return showModalBottomSheet<PaymentMethod>(
    context: context,
    builder: (_) => const _PaymentMethodSheet(),
  );
}

class _PaymentMethodSheet extends StatefulWidget {
  const _PaymentMethodSheet();

  @override
  State<_PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<_PaymentMethodSheet> {
  PaymentMethod _method = PaymentMethod.cash;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(loc.paymentSheetTitle, style: text.headlineSmall),
            const SizedBox(height: 12),
            _option(loc.paymentCash, PaymentMethod.cash),
            _option(loc.paymentCardTpe, PaymentMethod.cardTpe),
            const SizedBox(height: 8),
            Text(
              loc.paymentNote,
              style: text.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_method),
                child: Text(loc.confirmOrder),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(String label, PaymentMethod value) {
    final selected = _method == value;
    return ListTile(
      onTap: () => setState(() => _method = value),
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? AppColors.pink600 : AppColors.muted,
      ),
      title: Text(label),
    );
  }
}
