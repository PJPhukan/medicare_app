import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Selectable filter chip.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? c : context.inputBg,
          borderRadius: AppBorderRadius.pill,
          border: Border.all(
            color: selected ? c : context.borderCol,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(
                  size: 13,
                  // context.secondaryText, not AppColors.textSecondary: that
                  // constant is the DARK-theme value (a light slate meant for
                  // a dark background) and a raw Text/IconTheme never adapts
                  // it — in light mode it rendered as near-invisible light
                  // text on a light chip.
                  color: selected ? AppColors.textInverse : context.secondaryText,
                ),
                child: icon!,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: selected ? AppColors.textInverse : context.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Removable input chip (e.g. tags).
class AppInputChip extends StatelessWidget {
  const AppInputChip({
    super.key,
    required this.label,
    required this.onRemove,
    this.color,
  });

  final String label;
  final VoidCallback onRemove;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 6, top: 5, bottom: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTypography.labelSm.copyWith(color: c)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close_rounded, size: 14, color: c),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrollable chip row.
class AppChipRow extends StatelessWidget {
  const AppChipRow({
    super.key,
    required this.chips,
    this.padding,
  });

  final List<Widget> chips;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: chips
            .expand((c) => [c, const SizedBox(width: 8)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}
