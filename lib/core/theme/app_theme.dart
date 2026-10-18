import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_surfaces.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 28;

  static const RoundedRectangleBorder _shapeMd = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
  );

  static const RoundedRectangleBorder _shapeLg = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusLg)),
  );

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.blue600,
    onPrimary: AppColors.neutral0,
    secondary: AppColors.pink600,
    onSecondary: AppColors.neutral0,
    secondaryContainer: AppColors.softPink,
    onSecondaryContainer: AppColors.navy900,
    tertiary: AppColors.navy900,
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
    primary: AppColors.blue600,
    onPrimary: AppColors.neutral0,
    secondary: AppColors.pink600,
    onSecondary: AppColors.neutral0,
    secondaryContainer: AppColors.navy900,
    onSecondaryContainer: AppColors.neutral0,
    tertiary: AppColors.pink600,
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
    final textTheme = AppTypography.textTheme.apply(
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
      splashFactory: InkRipple.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: surfaces.surface,
        foregroundColor: AppColors.navy900,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h3.copyWith(color: AppColors.navy900),
      ),

      cardTheme: CardThemeData(
        color: surfaces.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: _shapeLg,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pink600,
          foregroundColor: AppColors.neutral0,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.muted,
          elevation: 0,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.button,
          shape: const StadiumBorder(),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.pink600,
          foregroundColor: AppColors.neutral0,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.muted,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.button,
          shape: const StadiumBorder(),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue600,
          side: const BorderSide(color: AppColors.blue600),
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.button.copyWith(color: AppColors.blue600),
          shape: const StadiumBorder(),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pink600,
          textStyle: AppTypography.label.copyWith(color: AppColors.pink600),
          shape: _shapeMd,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaces.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
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
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: surfaces.border,
        thickness: 1,
        space: 1,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaces.surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 25,
            color: states.contains(WidgetState.selected)
                ? AppColors.pink600
                : AppColors.navy900,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.caption.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.pink600
                : AppColors.navy900,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
