import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Universal text widget with named constructors for every typography scale.
///
/// Use instead of raw [Text] to stay on-design without importing
/// [AppTypography] everywhere.
///
/// ```dart
/// AppText.h1('Dashboard')
/// AppText.bodyMd('Take 1 tablet with water')
/// AppText.labelSm('BLOOD PRESSURE', color: AppColors.teal)
/// ```
class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    required this.style,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
  });

  // ── Private helper ───────────────────────────────────────────────────────────

  static AppText _make(
    TextStyle style,
    String text, {
    Key? key,
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
  }) =>
      AppText(
        text,
        key: key,
        style: style,
        color: color,
        fontWeight: fontWeight,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
      );

  // ── Display ──────────────────────────────────────────────────────────────────

  factory AppText.display1(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.display1, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.display2(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.display2, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  // ── Headings ─────────────────────────────────────────────────────────────────

  factory AppText.h1(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.h1, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.h2(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.h2, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.h3(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.h3, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  // ── Body ─────────────────────────────────────────────────────────────────────

  factory AppText.bodyLg(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.bodyLg, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.bodyMd(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.bodyMd, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.bodySm(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.bodySm, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.bodyXs(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.bodyXs, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  // ── Labels ───────────────────────────────────────────────────────────────────

  factory AppText.labelLg(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.labelLg, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.labelMd(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.labelMd, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.labelSm(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.labelSm, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.labelXs(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.labelXs, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  // ── Caption / Overline ───────────────────────────────────────────────────────

  factory AppText.caption(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.caption, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.overline(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.overline, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  // ── Stats ────────────────────────────────────────────────────────────────────

  factory AppText.statXl(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.statXl, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.statLg(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.statLg, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  factory AppText.statMd(String text, {Color? color, FontWeight? fontWeight,
      TextAlign? textAlign, int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.statMd, text, key: key, color: color,
          fontWeight: fontWeight, textAlign: textAlign, maxLines: maxLines,
          overflow: overflow, softWrap: softWrap);

  // ── Error / hint helpers ─────────────────────────────────────────────────────

  factory AppText.error(String text, {TextAlign? textAlign,
      int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.bodyXs, text, key: key,
          color: AppColors.error, textAlign: textAlign,
          maxLines: maxLines, overflow: overflow, softWrap: softWrap);

  factory AppText.hint(String text, {TextAlign? textAlign,
      int? maxLines, TextOverflow? overflow, bool? softWrap, Key? key}) =>
      AppText._make(AppTypography.bodyXs, text, key: key,
          color: AppColors.textHint, textAlign: textAlign,
          maxLines: maxLines, overflow: overflow, softWrap: softWrap);

  // ─────────────────────────────────────────────────────────────────────────────

  final String text;
  final TextStyle style;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final resolved = style.copyWith(
      color: color ?? _adaptColor(context, style.color),
      fontWeight: fontWeight,
    );
    return Text(
      text,
      style: resolved,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      softWrap: softWrap,
      semanticsLabel: semanticsLabel,
    );
  }

  static Color _adaptColor(BuildContext context, Color? styleColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (styleColor == AppColors.textPrimary) {
      return isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    }
    if (styleColor == AppColors.textSecondary) {
      return isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    }
    if (styleColor == AppColors.textHint) {
      return isDark ? AppColors.textHint : AppColors.textHintLight;
    }
    return styleColor ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight);
  }
}
