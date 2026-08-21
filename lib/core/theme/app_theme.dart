import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_surfaces.dart';
import 'app_typography.dart';

/// Thème applicatif SUP2I FOOD — Material 3, variantes claire et sombre.
///
/// Les tokens de marque ([AppColors]) restent constants ; les surfaces neutres
/// basculent via [AppSurfaces]. Ne pas définir de couleur de surface en dur
/// dans les écrans : passer par `context.surfaces` ou le thème.
class AppTheme {
  AppTheme._();

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  static const RoundedRectangleBorder _shapeMd = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
  );

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.navy900,
    onPrimary: AppColors.neutral0,
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

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.pink600,
    onPrimary: AppColors.neutral0,
    secondary: AppColors.pink500,
    onSecondary: AppColors.neutral0,
    secondaryContainer: AppColors.pink600,
    onSecondaryContainer: AppColors.neutral0,
    tertiary: AppColors.blue600,
    onTertiary: AppColors.neutral0,
    error: AppColors.error,
    onError: AppColors.neutral0,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkText,
    surfaceContainerHighest: AppColors.darkBackground,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.darkBorder,
  );

  static ThemeData get light => _build(_lightColorScheme, AppSurfaces.light);
  static ThemeData get dark => _build(_darkColorScheme, AppSurfaces.dark);

  static ThemeData _build(ColorScheme scheme, AppSurfaces surfaces) {
    final TextTheme textTheme = AppTypography.textTheme.apply(
      bodyColor: surfaces.text,
      displayColor: surfaces.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surfaces.background,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[surfaces],

      appBarTheme: AppBarTheme(
        backgroundColor: surfaces.surface,
        foregroundColor: surfaces.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h3.copyWith(color: surfaces.text),
      ),

      cardTheme: CardThemeData(
        color: surfaces.surface,
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
          side: BorderSide(color: surfaces.border),
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
        fillColor: surfaces.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTypography.bodyM.copyWith(color: surfaces.muted),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(color: surfaces.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(color: surfaces.border),
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

      dividerTheme: DividerThemeData(
        color: surfaces.border,
        thickness: 1,
        space: 1,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaces.surface,
        indicatorColor: surfaces.background,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : surfaces.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.caption.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : surfaces.muted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
