import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// A label–value pair row used in health records, profiles, and detail screens.
///
/// ```dart
/// AppInfoLabelText(
///   label: 'Blood Type',
///   value: 'A+',
///   accentColor: AppColors.teal,
/// )
/// ```
class AppInfoLabelText extends StatelessWidget {
  const AppInfoLabelText({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
    this.valueColor,
    this.layout = AppInfoLabelLayout.row,
    this.badge,
    this.padding,
    this.onTap,
  });

  final String label;
  final String value;

  /// Optional leading icon.
  final IconData? icon;

  /// Colour applied to the leading icon and the label. Defaults to teal.
  final Color? accentColor;

  /// Override colour for the value text.
  final Color? valueColor;

  /// Whether to render label and value in a [row] (side-by-side) or
  /// [column] (stacked, label above value).
  final AppInfoLabelLayout layout;

  /// Optional badge widget placed to the right of [value] (e.g. a status chip).
  final Widget? badge;

  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.teal;

    final labelWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            // context.secondaryText, not AppColors.textSecondary: this is
            // the label half of every info row across the app (medicine
            // details, health profiles, ...) — the raw constant is the
            // dark-theme value and never adapts, so every one of these
            // labels rendered near-invisible in light mode.
            color: context.secondaryText,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    final valueWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodyMd.copyWith(
              color: valueColor ?? context.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          badge!,
        ],
      ],
    );

    Widget content;

    if (layout == AppInfoLabelLayout.row) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: labelWidget),
          const SizedBox(width: 12),
          valueWidget,
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          labelWidget,
          const SizedBox(height: 3),
          valueWidget,
        ],
      );
    }

    final inner = Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: content,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.mdAll,
        child: inner,
      );
    }
    return inner;
  }
}

enum AppInfoLabelLayout { row, column }

// ─── Grouped card variant ─────────────────────────────────────────────────────

/// A card that groups multiple [AppInfoLabelText] items with dividers.
///
/// ```dart
/// AppInfoCard(
///   title: 'Health Info',
///   items: [
///     AppInfoLabelText(label: 'Blood Type', value: 'A+'),
///     AppInfoLabelText(label: 'Height', value: '5\'10"'),
///   ],
/// )
/// ```
class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    this.title,
    this.accentColor,
    required this.items,
    this.padding,
  });

  final String? title;
  final Color? accentColor;
  final List<AppInfoLabelText> items;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                title!,
                style: AppTypography.labelMd.copyWith(
                  color: accentColor ?? AppColors.teal,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ...List.generate(items.length * 2 - 1, (i) {
            if (i.isOdd) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: context.borderCol),
              );
            }
            final item = items[i ~/ 2];
            return Padding(
              padding: (padding ?? const EdgeInsets.symmetric(horizontal: 16))
                  .add(EdgeInsets.zero),
              child: AppInfoLabelText(
                label: item.label,
                value: item.value,
                icon: item.icon,
                accentColor: item.accentColor,
                valueColor: item.valueColor,
                layout: item.layout,
                badge: item.badge,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onTap: item.onTap,
              ),
            );
          }),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}
