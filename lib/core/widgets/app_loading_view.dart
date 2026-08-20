import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Indicateur de chargement centré, réutilisable pour l'état « loading »
/// (DoD : loading/empty/offline/timeout traités sur chaque écran).
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.pink600),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: text.bodyMedium?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
