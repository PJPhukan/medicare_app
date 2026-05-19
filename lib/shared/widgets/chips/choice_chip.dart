import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'app_base_chip.dart';

/// Single-select chip for "choose one" option groups.
///
/// Wrap a list of these in a [Row] or [AppChipRow] and maintain [selectedValue]
/// externally. Each chip calls [onSelected] with its own [value].
///
/// ```dart
/// AppChoiceChip<String>(
///   label: 'Weekly',
///   value: 'weekly',
///   groupValue: _frequency,
///   onSelected: (v) => setState(() => _frequency = v),
/// )
/// ```
class AppChoiceChip<T> extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
    this.icon,
    this.color,
    this.size = AppChipSize.md,
    this.borderRadius,
    this.enabled = true,
    this.padding,
  });

  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T> onSelected;
  final IconData? icon;

  /// Accent colour for the selected state. Defaults to [AppColors.teal].
  final Color? color;

  final AppChipSize size;
  final BorderRadius? borderRadius;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppBaseChip(
      label: label,
      leadingIcon: icon,
      selected: value == groupValue,
      onTap: enabled ? () => onSelected(value) : null,
      color: color ?? AppColors.teal,
      size: size,
      borderRadius: borderRadius,
      enabled: enabled,
      padding: padding,
    );
  }
}

// ─── Choice chip group ────────────────────────────────────────────────────────

/// Convenience widget — renders a list of [AppChoiceChip] in a wrap layout.
///
/// ```dart
/// AppChoiceChipGroup<String>(
///   options: const ['Daily', 'Weekly', 'Monthly'],
///   selectedValue: _freq,
///   onSelected: (v) => setState(() => _freq = v),
/// )
/// ```
class AppChoiceChipGroup<T> extends StatelessWidget {
  const AppChoiceChipGroup({
    super.key,
    required this.options,
    required this.labels,
    required this.selectedValue,
    required this.onSelected,
    this.icons,
    this.color,
    this.size = AppChipSize.md,
    this.spacing = 8,
    this.runSpacing = 8,
    this.padding,
    this.scroll = false,
  }) : assert(options.length == labels.length,
            'options and labels must be the same length');

  final List<T> options;
  final List<String> labels;
  final List<IconData?>? icons;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final Color? color;
  final AppChipSize size;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;

  /// When true, renders a single horizontal scrollable row instead of a wrap.
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final chips = List.generate(
      options.length,
      (i) => AppChoiceChip<T>(
        label: labels[i],
        value: options[i],
        groupValue: selectedValue,
        onSelected: onSelected,
        icon: icons?[i],
        color: color,
        size: size,
      ),
    );

    if (scroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: Row(
          children: chips
              .expand((c) => [c, SizedBox(width: spacing)])
              .toList()
            ..removeLast(),
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Wrap(spacing: spacing, runSpacing: runSpacing, children: chips),
    );
  }
}
