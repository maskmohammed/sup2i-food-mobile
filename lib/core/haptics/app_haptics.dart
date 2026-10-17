import 'package:flutter/services.dart';

/// Retours haptiques de l'app (API native Flutter `HapticFeedback`).
///
/// Règle d'accessibilité (charte §15) : le haptique est **supplémentaire**,
/// jamais l'unique confirmation d'une action — un retour **visuel** subsiste
/// toujours (snackbar, navigation, écran dédié). Le système d'exploitation
/// respecte les réglages d'accessibilité (l'utilisateur peut couper l'haptique).
abstract final class AppHaptics {
  /// Action légère réussie (ex. ajout au panier).
  static void light() => HapticFeedback.lightImpact();

  /// Confirmation importante (ex. commande créée, commande prête).
  static void success() => HapticFeedback.mediumImpact();
}
