import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// Styles are cached static finals, not getters: a getter runs a GoogleFonts
// descriptor lookup and allocates a fresh TextStyle on every widget build.
abstract class AppTypography {
  // ─── Display (Space Grotesk) ────────────────────────────────────────────────
  static final TextStyle display1 = GoogleFonts.spaceGrotesk(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static final TextStyle display2 = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.3,
  );

  static final TextStyle h1 = GoogleFonts.spaceGrotesk(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static final TextStyle h2 = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static final TextStyle h3 = GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ─── Body (Inter via Google Fonts) ──────────────────────────────────────────
  static final TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static final TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.55,
  );

  static final TextStyle bodySm = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static final TextStyle bodyXs = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.4,
  );

  // ─── Labels ─────────────────────────────────────────────────────────────────
  static final TextStyle labelLg = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelMd = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelSm = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static final TextStyle labelXs = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textHint,
    letterSpacing: 0.8,
  );

  // ─── Caption / Overline ──────────────────────────────────────────────────────
  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static final TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textHint,
    letterSpacing: 1.2,
  );

  // ─── Button text ─────────────────────────────────────────────────────────────
  static final TextStyle buttonLg = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static final TextStyle buttonMd = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static final TextStyle buttonSm = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // ─── Number / Stat ──────────────────────────────────────────────────────────
  // ─── Stats ──────────────────────────────────────────────────────────────────
  // Every numeric style below is tabular: digits share one advance width, so a
  // value ticking 9→10, or a column of dose times, never shifts sideways. Also
  // slashed zero, which matters when a dosage is read at a glance.
  static const _figures = <FontFeature>[
    FontFeature.tabularFigures(),
    FontFeature.slashedZero(),
  ];

  static final TextStyle statXl = GoogleFonts.spaceGrotesk(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1,
    letterSpacing: -1,
    fontFeatures: _figures,
  );

  static final TextStyle statLg = GoogleFonts.spaceGrotesk(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1,
    letterSpacing: -0.5,
    fontFeatures: _figures,
  );

  static final TextStyle statMd = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1,
    fontFeatures: _figures,
  );

  /// Inline data values — dose times, quantities, durations. Tabular so lists
  /// of times align down the column.
  static final TextStyle data = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFeatures: _figures,
  );

  static final TextStyle dataSm = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.2,
    fontFeatures: _figures,
  );
}
