import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Design tokens — typographie.
/// Source de vérité : SUP2I_FOOD_CHARTE_GRAPHIQUE_COMPLETE_V1, section 10
/// (Système typographique).
///
/// Familles :
///   - Titres  : Montserrat (bold)
///   - Corps   : Inter (régulier, Label en semibold)
///
/// Notation `taille/interligne` de la charte convertie en [TextStyle.height]
/// (multiplicateur = interligne ÷ taille de police).
class AppTypography {
  AppTypography._();

  // Graisses
  static const FontWeight _bold = FontWeight.w700;
  static const FontWeight _semibold = FontWeight.w600;
  static const FontWeight _regular = FontWeight.w400;

  // --- Titres : Montserrat (bold) ---

  /// Display — 40/48, bold.
  static TextStyle get display => GoogleFonts.montserrat(
    fontSize: 40,
    height: 48 / 40,
    fontWeight: _bold,
    color: AppColors.neutral900,
  );

  /// H1 — 32/40, bold.
  static TextStyle get h1 => GoogleFonts.montserrat(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: _bold,
    color: AppColors.neutral900,
  );

  /// H2 — 24/32, bold.
  static TextStyle get h2 => GoogleFonts.montserrat(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: _bold,
    color: AppColors.neutral900,
  );

  /// H3 — 20/28, bold.
  static TextStyle get h3 => GoogleFonts.montserrat(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: _bold,
    color: AppColors.neutral900,
  );

  // --- Corps : Inter ---

  /// Body L — 16/24, régulier.
  static TextStyle get bodyL => GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: _regular,
    color: AppColors.neutral900,
  );

  /// Body M — 14/22, régulier.
  static TextStyle get bodyM => GoogleFonts.inter(
    fontSize: 14,
    height: 22 / 14,
    fontWeight: _regular,
    color: AppColors.neutral900,
  );

  /// Label — 13/18, semibold.
  static TextStyle get label => GoogleFonts.inter(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: _semibold,
    color: AppColors.neutral900,
  );

  /// Caption — 12/16, régulier.
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: _regular,
    color: AppColors.muted,
  );

  /// [TextTheme] Material 3 assemblé à partir des styles de la charte.
  static TextTheme get textTheme => TextTheme(
    // Titres Montserrat
    displayLarge: display,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge: h3,
    // Corps Inter
    bodyLarge: bodyL,
    bodyMedium: bodyM,
    bodySmall: caption,
    labelLarge: label,
    labelMedium: label,
    labelSmall: caption,
  );
}
