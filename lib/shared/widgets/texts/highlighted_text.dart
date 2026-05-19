import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Renders [text] with every occurrence of [query] highlighted.
///
/// Useful in search result lists where the matching term should stand out.
///
/// ```dart
/// AppHighlightedText(
///   text: 'Paracetamol 500mg',
///   query: 'para',
///   highlightColor: AppColors.teal,
/// )
/// ```
class AppHighlightedText extends StatelessWidget {
  const AppHighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightColor,
    this.highlightBackground,
    this.caseSensitive = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String text;

  /// The substring to highlight. An empty or blank query renders [text] as-is.
  final String query;

  /// Base text style. Defaults to [AppTypography.bodyMd].
  final TextStyle? style;

  /// Colour of the highlighted characters. Defaults to [AppColors.teal].
  final Color? highlightColor;

  /// Background behind the highlighted span. Null = transparent.
  final Color? highlightBackground;

  final bool caseSensitive;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final base = style ?? AppTypography.bodyMd;
    final q    = query.trim();

    if (q.isEmpty) {
      return Text(
        text,
        style: base,
        maxLines: maxLines,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
        textAlign: textAlign,
      );
    }

    final spans = _buildSpans(base, q);

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      textAlign: textAlign,
    );
  }

  List<TextSpan> _buildSpans(TextStyle base, String q) {
    final accent = highlightColor ?? AppColors.teal;
    final highlighted = base.copyWith(
      color: accent,
      fontWeight: FontWeight.w700,
      backgroundColor: highlightBackground,
    );

    final pattern = RegExp(RegExp.escape(q), caseSensitive: caseSensitive);
    final matches = pattern.allMatches(text);

    if (matches.isEmpty) {
      return [TextSpan(text: text, style: base)];
    }

    final spans = <TextSpan>[];
    int cursor = 0;

    for (final m in matches) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, m.start), style: base));
      }
      spans.add(TextSpan(text: text.substring(m.start, m.end), style: highlighted));
      cursor = m.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: base));
    }

    return spans;
  }
}
