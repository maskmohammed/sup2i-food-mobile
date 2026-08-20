import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Thème applicatif SUP2I FOOD — Material 3.
///
/// Assemble les design tokens ([AppColors], [AppTypography]) en un [ThemeData]
/// unique, source de vérité pour toute l'UI. Ne pas définir de couleur ou de
/// style en dur dans les écrans : passer par ce thème ou par les tokens.
class AppTheme {
  AppTheme._();

  // Rayons de coin (charte : sm 8 / md 12 / lg 16 / xl 24).
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  /// [ColorScheme] clair dérivé de la palette de marque.
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.navy900,
    onPrimary: AppColors.neutral0,
    primaryContainer: AppColors.blue600,
    onPrimaryContainer: AppColors.neutral0,
    secondary: AppColors.pink600,
    onSecondary: AppColors.neutral0,
    secondaryContainer: AppColors.pink500,
    onSecondaryContainer: AppColors.neutral0,
    tertiary: AppColors.blue600,
    onTertiary: AppColors.neutral0,
    error: AppColors.error,
    onError: AppColors.neutral0,
    surface: AppColors.neutral0,
    onSurface: AppColors.neutral900,
    surfaceContainerHighest: AppColors.neutral100,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
  );

  /// Forme standard (radius md) partagée par boutons, cartes et champs.
  static const RoundedRectangleBorder _shapeMd = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
  );

  /// Thème clair complet de l'application.
  static ThemeData get light {
    final ColorScheme scheme = _lightColorScheme;
    final TextTheme textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.neutral100,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutral0,
        foregroundColor: AppColors.neutral900,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h3,
      ),

      cardTheme: const CardThemeData(
        color: AppColors.neutral0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: _shapeMd,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.label,
          shape: _shapeMd,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.label,
          shape: _shapeMd,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.label,
          shape: _shapeMd,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: AppTypography.label,
          shape: _shapeMd,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral0,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTypography.bodyM.copyWith(color: AppColors.muted),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(color: AppColors.blue600, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.neutral0,
        indicatorColor: AppColors.neutral100,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.navy900
                : AppColors.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.caption.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.navy900
                : AppColors.muted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
