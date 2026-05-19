import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

// ─── Display texts ────────────────────────────────────────────────────────────

class DisplayText extends StatelessWidget {
  const DisplayText(this.text, {super.key, this.color, this.textAlign});
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.display1.copyWith(color: color),
    textAlign: textAlign,
  );
}

class H1 extends StatelessWidget {
  const H1(this.text, {super.key, this.color, this.textAlign});
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.h1.copyWith(color: color),
    textAlign: textAlign,
  );
}

class H2 extends StatelessWidget {
  const H2(this.text, {super.key, this.color, this.textAlign});
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.h2.copyWith(color: color),
    textAlign: textAlign,
  );
}

class H3 extends StatelessWidget {
  const H3(this.text, {super.key, this.color, this.textAlign});
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.h3.copyWith(color: color),
    textAlign: textAlign,
  );
}

// ─── Body texts ───────────────────────────────────────────────────────────────

class BodyLg extends StatelessWidget {
  const BodyLg(this.text, {super.key, this.color, this.textAlign, this.maxLines});
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.bodyLg.copyWith(color: color),
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: maxLines != null ? TextOverflow.ellipsis : null,
  );
}

class BodyMd extends StatelessWidget {
  const BodyMd(this.text, {super.key, this.color, this.textAlign, this.maxLines});
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.bodyMd.copyWith(color: color),
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: maxLines != null ? TextOverflow.ellipsis : null,
  );
}

class BodySm extends StatelessWidget {
  const BodySm(this.text, {super.key, this.color, this.textAlign, this.maxLines});
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.bodySm.copyWith(color: color),
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: maxLines != null ? TextOverflow.ellipsis : null,
  );
}

class LabelMd extends StatelessWidget {
  const LabelMd(this.text, {super.key, this.color, this.textAlign});
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.labelMd.copyWith(color: color),
    textAlign: textAlign,
  );
}

class CaptionText extends StatelessWidget {
  const CaptionText(this.text, {super.key, this.color, this.textAlign});
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.caption.copyWith(color: color ?? AppColors.textSecondary),
    textAlign: textAlign,
  );
}

// ─── Rich text helpers ────────────────────────────────────────────────────────

class HighlightText extends StatelessWidget {
  const HighlightText({
    super.key,
    required this.text,
    required this.highlight,
    this.baseStyle,
    this.highlightColor,
  });

  final String text;
  final String highlight;
  final TextStyle? baseStyle;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(text, style: baseStyle ?? AppTypography.bodyMd);
    }
    final base = baseStyle ?? AppTypography.bodyMd;
    final hColor = highlightColor ?? AppColors.teal;
    final lower = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    int idx;
    while ((idx = lower.indexOf(lowerHighlight, start)) != -1) {
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: base));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + highlight.length),
        style: base.copyWith(color: hColor, fontWeight: FontWeight.w700),
      ));
      start = idx + highlight.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: base));
    }
    return RichText(text: TextSpan(children: spans));
  }
}
