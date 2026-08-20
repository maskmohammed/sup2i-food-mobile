import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Vue d'état centrée réutilisable (vide / erreur) : illustration ronde,
/// titre, message et action optionnelle.
///
/// Gabarit commun des écrans d'état documentés dans `docs/design/`
/// (panier vide, aucun résultat, créneau complet…).
class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor,
    this.actionLabel,
    this.onAction,
  });

  /// Variante « état vide » (icône neutre).
  const AppStateView.empty({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : iconColor = AppColors.muted;

  /// Variante « erreur » (icône rouge). À alimenter par le `code` API en M2.
  const AppStateView.error({
    super.key,
    this.icon = Icons.error_outline,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : iconColor = AppColors.error;

  final IconData icon;
  final String title;
  final String message;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool hasAction = actionLabel != null && onAction != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.neutral0,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: iconColor ?? AppColors.muted),
            ),
            const SizedBox(height: 20),
            Text(title, style: text.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              style: text.bodyMedium?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            if (hasAction) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
