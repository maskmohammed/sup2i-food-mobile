import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Couleurs de surface sensibles au thème (clair/sombre).
///
/// Les tokens de marque ([AppColors.navy900], `pink600`, sémantiques…) restent
/// constants ; seules les neutres (surface, fond, texte, muted, bordure)
/// basculent en mode sombre. Accès via `context.surfaces`.
@immutable
class AppSurfaces extends ThemeExtension<AppSurfaces> {
  const AppSurfaces({
    required this.surface,
    required this.background,
    required this.text,
    required this.muted,
    required this.border,
  });

  final Color surface;
  final Color background;
  final Color text;
  final Color muted;
  final Color border;

  static const AppSurfaces light = AppSurfaces(
    surface: AppColors.neutral0,
    background: AppColors.neutral100,
    text: AppColors.neutral900,
    muted: AppColors.muted,
    border: AppColors.border,
  );

  static const AppSurfaces dark = AppSurfaces(
    surface: AppColors.darkSurface,
    background: AppColors.darkBackground,
    text: AppColors.darkText,
    muted: AppColors.darkMuted,
    border: AppColors.darkBorder,
  );

  @override
  AppSurfaces copyWith({
    Color? surface,
    Color? background,
    Color? text,
    Color? muted,
    Color? border,
  }) => AppSurfaces(
    surface: surface ?? this.surface,
    background: background ?? this.background,
    text: text ?? this.text,
    muted: muted ?? this.muted,
    border: border ?? this.border,
  );

  @override
  AppSurfaces lerp(ThemeExtension<AppSurfaces>? other, double t) {
    if (other is! AppSurfaces) return this;
    return AppSurfaces(
      surface: Color.lerp(surface, other.surface, t)!,
      background: Color.lerp(background, other.background, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

extension AppSurfacesX on BuildContext {
  AppSurfaces get surfaces => Theme.of(this).extension<AppSurfaces>()!;
}
