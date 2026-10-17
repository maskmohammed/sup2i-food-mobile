import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography locked to the SUP2I FOOD graphic charter.
class AppTypography {
  AppTypography._();

  static const FontWeight _bold = FontWeight.w700;
  static const FontWeight _semibold = FontWeight.w600;
  static const FontWeight _regular = FontWeight.w400;

  static TextStyle get display => GoogleFonts.montserrat(
    fontSize: 40,
    height: 48 / 40,
    fontWeight: _bold,
    color: AppColors.navy900,
  );

  static TextStyle get h1 => GoogleFonts.montserrat(
    fontSize: 40,
    height: 48 / 40,
    fontWeight: _bold,
    color: AppColors.navy900,
  );

  static TextStyle get h2 => GoogleFonts.montserrat(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: _bold,
    color: AppColors.navy900,
  );

  static TextStyle get h3 => GoogleFonts.montserrat(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: _bold,
    color: AppColors.navy900,
  );

  static TextStyle get bodyL => GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: _regular,
    color: AppColors.neutral900,
  );

  static TextStyle get bodyM => GoogleFonts.inter(
    fontSize: 14,
    height: 22 / 14,
    fontWeight: _regular,
    color: AppColors.neutral900,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: _semibold,
    color: AppColors.neutral900,
  );

  static TextStyle get button => GoogleFonts.montserrat(
    fontSize: 14,
    height: 16 / 14,
    fontWeight: _bold,
    color: AppColors.neutral0,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: _regular,
    color: AppColors.muted,
  );

  static TextTheme get textTheme => TextTheme(
    displayLarge: display,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge: h3,
    bodyLarge: bodyL,
    bodyMedium: bodyM,
    bodySmall: caption,
    labelLarge: label,
    labelMedium: label,
    labelSmall: caption,
  );
}
