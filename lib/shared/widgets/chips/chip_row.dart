import 'package:flutter/material.dart';

/// Horizontally scrollable chip row — no clip on the edges.
///
/// Chips are spaced [gap] apart. Pass [padding] to add leading/trailing
/// insets (useful so chips don't sit flush against a screen edge).
///
/// ```dart
/// AppChipRow(
///   gap: 8,
///   padding: const EdgeInsets.symmetric(horizontal: 16),
///   chips: [
///     AppFilterChip(label: 'All',   selected: true,  onTap: () {}),
///     AppFilterChip(label: 'Today', selected: false, onTap: () {}),
///   ],
/// )
/// ```
class AppChipRow extends StatelessWidget {
  const AppChipRow({
    super.key,
    required this.chips,
    this.gap = 8,
    this.padding,
    this.scrollController,
  });

  final List<Widget> chips;
  final double gap;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: chips
            .expand((c) => [c, SizedBox(width: gap)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

// ─── Wrap variant ─────────────────────────────────────────────────────────────

/// Wrapping chip layout — chips flow to a new line when the row fills up.
///
/// ```dart
/// AppChipWrap(
///   chips: myTags.map((t) => AppTagChip(label: t)).toList(),
/// )
/// ```
class AppChipWrap extends StatelessWidget {
  const AppChipWrap({
    super.key,
    required this.chips,
    this.spacing = 8,
    this.runSpacing = 8,
    this.padding,
    this.alignment = WrapAlignment.start,
  });

  final List<Widget> chips;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: alignment,
        children: chips,
      ),
    );
  }
}
