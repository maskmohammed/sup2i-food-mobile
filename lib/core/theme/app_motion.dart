import 'package:flutter/material.dart';

/// Charte d'animation — source de vérité des durées/courbes (design system).
///
/// Toute animation d'interface doit s'appuyer sur ces constantes plutôt que sur
/// des valeurs en dur, et respecter `prefers-reduced-motion` via [reduceMotion]
/// / [effective].
abstract final class AppMotion {
  /// Transitions d'interface courantes (apparition, bascule) : 160–220 ms.
  static const Duration ui = Duration(milliseconds: 200);
  static const Duration uiFast = Duration(milliseconds: 160);

  /// Pulsation de mise en avant (écran « commande prête ») : 250–400 ms.
  static const Duration pulse = Duration(milliseconds: 320);

  /// Micro-scale de retour à l'ajout au panier : 160–200 ms.
  static const Duration cartAdd = Duration(milliseconds: 180);

  /// Anti-rebond de la saisie de recherche : 250–300 ms.
  static const Duration searchDebounce = Duration(milliseconds: 280);

  /// Courbe standard des transitions d'interface.
  static const Curve standard = Curves.easeInOut;

  /// Courbe légèrement rebondie pour les retours (scale d'ajout).
  static const Curve emphasized = Curves.easeOutBack;

  /// Vrai si l'utilisateur a demandé la réduction des animations.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  /// Durée effective : 0 si les animations sont réduites, sinon [duration].
  static Duration effective(BuildContext context, Duration duration) =>
      reduceMotion(context) ? Duration.zero : duration;
}
