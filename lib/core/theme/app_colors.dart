import 'package:flutter/material.dart';

/// Design tokens — couleurs.
/// Source de vérité : SUP2I_FOOD_CHARTE_GRAPHIQUE_COMPLETE_V1, section 09 (Palette chromatique)
/// et Annexe A (Tokens de référence). Ne pas modifier ces valeurs sans
/// passer par une revue d'équipe (charte section 29, Gouvernance de marque).
class AppColors {
  AppColors._();

  // Palette cœur (brand)
  static const Color navy900 = Color(0xFF160F67);
  static const Color pink600 = Color(0xFFC31A6F);
  static const Color blue600 = Color(0xFF1F25B5);
  static const Color pink500 = Color(0xFFE6318C);

  // Neutres
  static const Color neutral900 = Color(0xFF252A3A);
  static const Color neutral100 = Color(0xFFF4F5F8);
  static const Color neutral0 = Color(0xFFFFFFFF);

  // Palette sémantique (statuts, jamais utilisée seule sans libellé — cf. charte section 15)
  static const Color success = Color(0xFF22C55E);
  static const Color info = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Tons utilitaires non gelés par la charte, dérivés pour usage UI courant
  static const Color border = Color(0xFFE4E6EE);
  static const Color muted = Color(0xFF8A8D99);

  // Neutres sombres (mode nuit) — hors charte, dérivés pour l'UI.
  static const Color darkSurface = Color(0xFF1C1D24);
  static const Color darkBackground = Color(0xFF121317);
  static const Color darkText = Color(0xFFE8EAF2);
  static const Color darkMuted = Color(0xFF9AA0B4);
  static const Color darkBorder = Color(0xFF33364A);
}
